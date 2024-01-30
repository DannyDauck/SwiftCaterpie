//
//  CodeAnalyzerViewModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import Foundation
import SwiftUI

@MainActor
class CodeAnalyzerViewModel: ObservableObject{
    
    init(sourceCode: String) {
        self.sourceCode = sourceCode
        
        analyzeCode()
    }
    @Published var sourceCode: String
    //Contains all code snippets, where each array inside is a line
    var analyzedCode: [[CodeSnippet]] = []
    @Published var codeItems: [[CodeItem]] = []
    @ObservedObject var settingsVM =  SettingsViewModel()
    private var colorIndex = 0
    private var brightness = 0
    
    func analyzeCode(){
        breakeCodeIntoLines()
        checkForCommentsAndStrings()
        checkForScopeStart()
        checkForScopeEnds()
        addLineNumbers()
        createCodeItems()
    }
    
    private func breakeCodeIntoLines(){
        var emptyLineCounter = 0
        let codeLines = sourceCode.components(separatedBy: "\n")
        for line in codeLines{
            if line.replacingOccurrences(of: " ", with: "").isEmpty && settingsVM.removeUnusedEmptyBreakeLines{
                emptyLineCounter += 1
            }else{
                emptyLineCounter = 0
            }
            if emptyLineCounter <= settingsVM.maxEmptyBreakLines{
                analyzedCode.append([CodeSnippet(string: line.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "quotationIn", with: "\""), typ: .undefined)])
            }
        }
    }
    
    private func checkForCommentsAndStrings(){
        var workingArray: [[CodeSnippet]] = []
        for line in analyzedCode{
            let newLine = seperateStrings(line)
            var lineToAdd: [CodeSnippet] = []
            for codeSnippet in newLine{
                if codeSnippet.typ != .string{
                    if codeSnippet.string.contains("//"){
                        if codeSnippet.string.hasPrefix("//"){
                            lineToAdd.append(codeSnippet.cloneSnippetWithNewType(.comment))
                        }else{
                            let components = codeSnippet.string.components(separatedBy: "//")
                            if !components.first!.isEmpty{
                                lineToAdd.append(CodeSnippet(string: components.first!, typ: .undefined))
                                workingArray.append([CodeSnippet(string: "//" + components.last!, typ: .comment)])
                            }
                        }
                    }else{
                        lineToAdd.append(codeSnippet)
                    }
                    
                }else{
                    lineToAdd.append(codeSnippet)
                }
            }
            workingArray.append(seperateLineByCodeBlockEnd(seperateLineByCodeBlockStart(lineToAdd)))
        }
        analyzedCode = markCommentBlocks(workingArray)
    }
    private func seperateStrings(_ line:[CodeSnippet])->[CodeSnippet]{
        var newLine: [CodeSnippet] = []
        var isString = false
        let escapeIdent: String = UUID().uuidString
        for snippetIn in line{
            if snippetIn.typ != .comment{
                //replacing quotations inbetween a string with a random string element escapeIdent
                let snippet = snippetIn.replaceString(snippetIn.string.replacingOccurrences(of: "\\" + "\"" + "\"", with: escapeIdent + "\""))
                
                if snippet.string.hasPrefix("\""){
                    isString = true
                }
                var newStrings = snippet.string.components(separatedBy: "\"")
                if isString{
                    newStrings.removeFirst()
                }
                
                for string in newStrings {
                    //replace ecapeIdent again with the escape sequence for for a quotation
                    if isString{
                        newLine.append(CodeSnippet(string: "\"" + string.replacingOccurrences(of: escapeIdent, with: "\\" + "\"") + "\"", typ: .string))
                        isString.toggle()
                    }else{
                        newLine.append(CodeSnippet(string: string.replacingOccurrences(of: escapeIdent, with: "\\" + "\""), typ: .undefined))
                        isString.toggle()
                    }
                }
            }else{
                newLine.append(snippetIn)
            }
        }
        
        return newLine
        
    }
    
    
    
    
    private func seperateLineByCodeBlockStart(_ line:[CodeSnippet])->[CodeSnippet]{
        var newLine: [CodeSnippet] = []
        if !line.isEmpty{
            for snippet in line{
                if snippet.string.contains("/*") && snippet.typ != .string && snippet.typ != .debuggingInfo{
                    if snippet.string.hasPrefix("/*"){
                        let newStrings = snippet.string.components(separatedBy: "/*")
                        if newStrings.isEmpty{
                            newLine.append(CodeSnippet(string: "/*", typ: .undefined))
                        }
                        for string in newStrings{
                            if !string.isEmpty{
                                newLine.append(CodeSnippet(string: "/*" + string , typ: .undefined))
                            }
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "/*")
                        newLine.append(CodeSnippet(string: newStrings.first!, typ: .undefined))
                        newStrings.removeFirst()
                        for string in newStrings{
                            if !string.isEmpty{
                                newLine.append(CodeSnippet(string: "/*" + string , typ: .undefined))
                            }
                        }
                    }
                }else{
                    newLine.append(snippet)
                }
            }
        }
        return newLine
    }
    
    private func seperateLineByCodeBlockEnd(_ line:[CodeSnippet])->[CodeSnippet]{
        /*seems to be a little complicate but in combination with seperateLineByCodeBlockStart this should seperate all comment blocks even if there is more than ohne comment-block in one line*/
        var newLine: [CodeSnippet] = []
        if !line.isEmpty{
            for snippet in line{
                if snippet.string.contains("*/") && snippet.typ != .string && snippet.typ != .debuggingInfo{
                    if snippet.string.hasPrefix("*/"){
                        var newStrings = snippet.string.components(separatedBy: "*/")
                        newLine.append(CodeSnippet(string: "*/", typ: .comment))
                        newStrings.removeLast()
                        if !newStrings.isEmpty{
                            for string in newStrings {
                                if !string.isEmpty{
                                    newLine.append(CodeSnippet(string: string + "*/" , typ: .undefined))
                                }
                            }
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "*/")
                        newStrings.removeLast()
                        if !newStrings.isEmpty{
                            for string in newStrings {
                                if !string.isEmpty{
                                    newLine.append(CodeSnippet(string: string + "*/" , typ: .undefined))
                                }
                            }
                        }
                    }
                }else{
                    newLine.append(snippet)
                }
            }
        }
        return newLine
    }
    
    private func markCommentBlocks(_ array: [[CodeSnippet]])->[[CodeSnippet]]{
        var commentBlockDetected = false
        var commentBlockHasEnded = true
        var workingArray: [[CodeSnippet]] = []
        for line in array{
            var newLine: [CodeSnippet] = []
            for snippet in line{
                if snippet.typ == .debuggingInfo{
                    newLine.append(snippet)
                }else{
                    if snippet.string.hasPrefix("/*"){
                        commentBlockDetected = true
                    }
                    if snippet.string.hasSuffix("*/"){
                        if commentBlockDetected{
                            commentBlockDetected = false
                            commentBlockHasEnded = false
                        }else{
                            newLine.append(snippet)
                            newLine.append(CodeSnippet(string: "Close-comment-block-tag without open comment-block", typ: .warning))
                        }
                    }
                    if commentBlockDetected{
                        newLine.append(snippet.cloneSnippetWithNewType(.comment))
                    }else{
                        if commentBlockHasEnded{
                            newLine.append(snippet)
                        }else{
                            newLine.append(snippet.cloneSnippetWithNewType(.comment))
                            commentBlockHasEnded = true
                        }
                    }
                }
            }
            workingArray.append(newLine)
        }
        return workingArray
    }
    private func addLineNumbers(){
        var workingArray: [[CodeSnippet]] = []
        
        for lineNumber in analyzedCode.indices{
            var newLine: [CodeSnippet] = []
            newLine.append(CodeSnippet(string: "\(lineNumber + 1)", typ: .lineNumber))
            for snippet in analyzedCode[lineNumber]{
                newLine.append(snippet)
            }
            workingArray.append(newLine)
        }
        analyzedCode = workingArray
    }
    private func checkForScopeStart(){
        var workingArray: [[CodeSnippet]] = []
        let alreadyChecked: [SnippetType] = [.comment, .string]
        for line in analyzedCode{
            var newLine: [CodeSnippet] = []
            for snippet in line{
                if alreadyChecked.contains(snippet.typ){
                    newLine.append(snippet)
                }
                else {
                    if snippet.string.hasPrefix("import"){
                        newLine.append(snippet.cloneSnippetWithNewType(.importType))
                    }else if snippet.string.contains("@"){
                        if snippet.string.hasPrefix("@"){
                            let components = snippet.string.components(separatedBy: " ")
                            newLine.append(CodeSnippet(string: components.first!, typ: .atDeclaration))
                            newLine.append(snippet.replaceString(snippet.string.replacingOccurrences(of: components.first!, with: "")))
                        }
                    }else if snippet.string.contains("{"){
                        newLine.append(snippet.cloneSnippetWithNewType(.scopeStart))
                    }
                    else{
                        newLine.append(snippet)
                    }
                }
            }
            workingArray.append(newLine)
        }
        analyzedCode = workingArray
    }
    
    private func checkForScopeEnds(){
        var workingArray: [[CodeSnippet]] = []
        let alreadyChecked: [SnippetType] = [.comment, .string, .importType]
        for line in analyzedCode{
            var newLine: [CodeSnippet] = []
            for snippet in line{
                if alreadyChecked.contains(snippet.typ){
                    newLine.append(snippet)
                }else if snippet.string.contains("}"){
                    if snippet.string.replacingOccurrences(of: "}", with: "").isEmpty{
                        newLine.append(snippet.cloneSnippetWithNewType(.scopeEnd))
                    }
                    else if snippet.string.hasSuffix("}"){
                        newLine.append(snippet.replaceString(snippet.string.replacingOccurrences(of: "}", with: "")))
                        newLine.append(CodeSnippet(string: "}", typ: .scopeEnd))
                    }
                    else if snippet.string.hasPrefix("}"){
                        newLine.append(CodeSnippet(string: "}", typ: .scopeEnd))
                        newLine.append(snippet.replaceString(snippet.string.replacingOccurrences(of: "}", with: "")))
                    }else{
                        newLine.append(snippet.cloneSnippetWithNewType(.scopeEnd))
                    }
                }else{
                    newLine.append(snippet)
                }
            }
            workingArray.append(newLine)
        }
        analyzedCode = workingArray
    }
    private func createCodeItems(){
        var colorIndex = 1
        var brigthness = 0
        var indentation = 0
        var brigthnessContainer = [0]
        
        for line in analyzedCode{
            var newLine: [CodeItem] = []
            for snippet in line{
                if snippet.typ == .lineNumber{
                    newLine.append(CodeItem(snippet, color: .gray, brightness: 1.0))
                    newLine.append(CodeItem(string: String(repeating: "    ", count: max(0,indentation)), id: UUID(), type: .indentation, color: settingsVM.getScopeColor(colorIndex), brightness: 1, colorizeIndentation: true))
                }else if snippet.typ == .scopeStart{
                    newLine.append(CodeItem(snippet, color: settingsVM.getScopeColor(colorIndex),brightness: settingsVM.getBrightness(brigthness)))
                    brigthness += 1
                    colorIndex += 1
                    indentation += 1
                }else if snippet.typ == .scopeEnd{
                    indentation -= 1
                    colorIndex -= 1
                    brigthness -= 1
                    
                    //setting the indentation new before adding new CodeItem, because in this line the indentation has alrady been set
                    let indentationSnippet = newLine.filter{
                        $0.type == .indentation
                    }
                    if !indentationSnippet.isEmpty{
                        newLine[1].string = String(repeating: "    ", count: max(0,indentation))
                        newLine[1].color = settingsVM.getScopeColor(colorIndex)
                    }
                    
                    newLine.append(CodeItem(snippet, color: settingsVM.getScopeColor(colorIndex), brightness: settingsVM.getBrightness(brigthness)))
                }else if snippet.typ == .comment{
                    newLine.append(CodeItem(snippet, color: settingsVM.commentColor, brightness: 1.0))
                }else if snippet.typ == .importType{
                    newLine.append(CodeItem(snippet, color: settingsVM.importTypeColor, brightness: 1.0))
                }else if snippet.typ == .atDeclaration{
                    newLine.append(CodeItem(snippet, color: settingsVM.getScopeColor(colorIndex), brightness: 1.0, secondColor: settingsVM.atDeclarationHighlight))
                }else if snippet.typ == .string{
                    newLine.append(CodeItem(snippet, color: settingsVM.getScopeColor(colorIndex), brightness: 1.0, secondColor: settingsVM.stringHighlight))
                }else{
                    newLine.append(CodeItem(snippet, color: settingsVM.getScopeColor(colorIndex), brightness: settingsVM.getBrightness(brigthness)))
                }
            }
            codeItems.append(newLine)
        }
    }
}
