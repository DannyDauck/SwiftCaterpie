//
//  CodeAnalyzerViewModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import Foundation
import SwiftUI

class CodeAnalyzerViewModel: ObservableObject{
    
    init(sourceCode: String) {
        self.sourceCode = sourceCode
        
        analyzeCode()
    }
    @Published var sourceCode: String
    //Contains all code snippets, where each array inside is a line
    @Published var analyzedCode: [[CodeSnippet]] = []
    @ObservedObject var settingsVM =  SettingsViewModel()
    
    func analyzeCode(){
        breakeCodeIntoLines()
        checkForCommentsAndStrings()
        //checkForScopeStart()
        //checkForScopeEnds()
        addLineNumbers()
    }
    
    private func breakeCodeIntoLines(){
        var emptyLineCounter = 0
        let codeLines = sourceCode.components(separatedBy: "\n")
        print(codeLines)
        for line in codeLines{
            if line.replacingOccurrences(of: " ", with: "").isEmpty && settingsVM.removeUnusedEmptyBreakeLines{
                emptyLineCounter += 1
            }else{
                emptyLineCounter = 0
            }
            print(emptyLineCounter)
            print(line)
            if emptyLineCounter <= settingsVM.maxEmptyBreakLines{
                analyzedCode.append([CodeSnippet(string: line.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "quotationIn", with: "\""), type: .undefined)])
            }
        }
    }
    
    private func checkForCommentsAndStrings(){
        var workingArray: [[CodeSnippet]] = []
        for line in analyzedCode{
            let newLine = seperateStrings(line)
            var lineToAdd: [CodeSnippet] = []
            for codeSnippet in newLine{
                if codeSnippet.type != .string{
                    if codeSnippet.string.contains("//"){
                        if codeSnippet.string.hasPrefix("//"){
                            lineToAdd.append(codeSnippet.cloneSnippetWithNewType(.comment))
                        }else{
                            let components = codeSnippet.string.components(separatedBy: "//")
                            if !components.first!.isEmpty{
                                lineToAdd.append(CodeSnippet(string: components.first!, type: .undefined))
                                workingArray.append([CodeSnippet(string: "//" + components.last!, type: .comment)])
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
            if snippetIn.type != .comment{
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
                        newLine.append(CodeSnippet(string: "\"" + string.replacingOccurrences(of: escapeIdent, with: "\\" + "\"") + "\"", type: .string))
                        isString.toggle()
                    }else{
                        newLine.append(CodeSnippet(string: string.replacingOccurrences(of: escapeIdent, with: "\\" + "\""), type: .undefined))
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
                if snippet.string.contains("/*") && snippet.type != .string && snippet.type != .debuggingInfo{
                    if snippet.string.hasPrefix("/*"){
                        let newStrings = snippet.string.components(separatedBy: "/*")
                        if newStrings.isEmpty{
                            newLine.append(CodeSnippet(string: "/*", type: .undefined))
                        }
                        for string in newStrings{
                            if !string.isEmpty{
                                newLine.append(CodeSnippet(string: "/*" + string , type: .undefined))
                            }
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "/*")
                        newLine.append(CodeSnippet(string: newStrings.first!, type: .undefined))
                        newStrings.removeFirst()
                        for string in newStrings{
                            if !string.isEmpty{
                                newLine.append(CodeSnippet(string: "/*" + string , type: .undefined))
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
                if snippet.string.contains("*/") && snippet.type != .string && snippet.type != .debuggingInfo{
                    if snippet.string.hasPrefix("*/"){
                        var newStrings = snippet.string.components(separatedBy: "*/")
                        newLine.append(CodeSnippet(string: "*/", type: .comment))
                        newStrings.removeLast()
                        if !newStrings.isEmpty{
                            for string in newStrings {
                                if !string.isEmpty{
                                    newLine.append(CodeSnippet(string: string + "*/" , type: .undefined))
                                }
                            }
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "*/")
                        newStrings.removeLast()
                        if !newStrings.isEmpty{
                            for string in newStrings {
                                if !string.isEmpty{
                                    newLine.append(CodeSnippet(string: string + "*/" , type: .undefined))
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
                if snippet.type == .debuggingInfo{
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
                            newLine.append(CodeSnippet(string: "Close-comment-block-tag without open comment-block", type: .warning))
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
            newLine.append(CodeSnippet(string: "\(lineNumber + 1)", type: .lineNumber))
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
                if alreadyChecked.contains(snippet.type){
                    newLine.append(snippet)
                }else if snippet.string.contains("{"){
                    if snippet.string.hasPrefix("{"){
                        newLine.append(CodeSnippet(string: "{", type: .scopeBeginnings))
                    }
                    var newSnippets = snippet.string.components(separatedBy: "{")
                    for newCodeSnippet in newSnippets{
                        if !newCodeSnippet.isEmpty{
                            if newCodeSnippet == newSnippets.last && !snippet.string.hasSuffix("{"){
                                newLine.append(CodeSnippet(string: newCodeSnippet, type: .undefined))
                                workingArray.append(newLine)
                            }else{
                                newLine.append(CodeSnippet(string: newCodeSnippet + "{", type: .scopeBeginnings))
                                workingArray.append(newLine)
                                newLine = []
                            }
                        }
                    }
                }
            }
        }
        analyzedCode = workingArray
    }
    
    private func checkForScopeEnds(){
        var workingArray: [[CodeSnippet]] = []
        let alreadyChecked: [SnippetType] = [.comment, .string]
        for line in analyzedCode{
            var newLine: [CodeSnippet] = []
            for snippet in line{
                if alreadyChecked.contains(snippet.type){
                    newLine.append(snippet)
                }else{
                    if !snippet.string.isEmpty{
                        if snippet.string.replacingOccurrences(of: "}", with: "").isEmpty{
                            newLine.append(snippet.cloneSnippetWithNewType(.scopeEndings))
                            workingArray.append(newLine)
                            newLine = []
                        }
                    }
                    var newSnippets = snippet.string.components(separatedBy: "}")
                    for newCodeSnippet in newSnippets{
                        if newCodeSnippet == newSnippets.first{
                            if snippet.string.hasPrefix("}"){
                                workingArray.append(newLine)
                                newLine = []
                                newLine.append(CodeSnippet(string: "}" + newCodeSnippet, type: .scopeEndings))
                            }else {
                                newLine.append(CodeSnippet(string: newCodeSnippet, type: .undefined))
                            }
                        }else{
                            workingArray.append(newLine)
                            newLine = []
                            newLine.append(CodeSnippet(string: "}" + newCodeSnippet, type: .scopeEndings))
                        }
                        
                    }
                    if newSnippets.last!.hasSuffix("}"){
                        workingArray.append(newLine)
                        newLine = []
                        newLine.append(CodeSnippet(string: "}", type: .scopeEndings))
                    }
                }
            }
        }
        analyzedCode = workingArray
    }
}
