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
        self.settingsVM = SettingsViewModel.shared
        analyzeCode()
    }
    @Published var sourceCode: String
    //Contains all code snippets, where each array inside is a line
    @Published var analyzedCode: [[CodeSnippet]] = []
    @ObservedObject var settingsVM: SettingsViewModel
    
    func analyzeCode(){
        breakeCodeIntoLines()
        checkForCommentsAndStrings()
        
        addLineNumbers()
    }
    
    private func breakeCodeIntoLines(){
        var emptyLineCounter = 0
        let codeLines = sourceCode.components(separatedBy: "\n")

        for line in codeLines{
            if line.isEmpty && settingsVM.removeUnusedEmptyBreakeLines{
                emptyLineCounter += 1
            }else{
                emptyLineCounter = 0
            }
            if emptyLineCounter <= settingsVM.maxEmptyBreakLines{
                analyzedCode.append([CodeSnippet(string: line.trimmingCharacters(in: .whitespacesAndNewlines), type: .undefined)])
            }
        }
    }
    
    private func checkForCommentsAndStrings(){
        var workingArray: [[CodeSnippet]] = []
        for line in analyzedCode{
            var newLine = seperateStrings(line)
            for codeSnippet in newLine{
                if codeSnippet.type != .string{
                    if codeSnippet.string.contains("//"){
                        if codeSnippet.string.hasPrefix("//"){
                            workingArray.append([codeSnippet.cloneSnippetWithNewType(.comment)])
                        }else{
                            let newSnippets = codeSnippet.string.components(separatedBy: "//")
                            workingArray.append([CodeSnippet(string: "//" + newSnippets.last!, type: .comment)])
                            workingArray.append([CodeSnippet(string: newSnippets.first!, type: .undefined)])
                        }
                    }else{
                        //After seperating single comment lines, first seperate all Strings, then split by comment block ends, and finally split by comment block ends
                        workingArray.append(seperateLineByCodeBlockEnd(seperateLineByCodeBlockStart(seperateStrings(line))))
                    }
                }
            }
        }
        analyzedCode = markCommentBlocks(workingArray)
    }
    private func seperateStrings(_ line:[CodeSnippet])->[CodeSnippet]{
        var newLine: [CodeSnippet] = []
        var isString = false
        let escapeIdent: String = UUID().uuidString
        for snippetIn in line{
            //replacing qutations inbetween a string with a random string element escapeIdent
            var snippet = snippetIn.replaceString(snippetIn.string.replacingOccurrences(of: "\\" + "\"" + "\"", with: escapeIdent + "\""))
            if snippet.type != .comment{
                if snippet.string.hasPrefix("\""){
                    isString = true
                }
                let newStrings = snippet.string.components(separatedBy: "\"")
                
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
            }
        }
        
        return newLine
        
    }
    
    
    
    
    private func seperateLineByCodeBlockStart(_ line:[CodeSnippet])->[CodeSnippet]{
        var newLine: [CodeSnippet] = []
        if !line.isEmpty{
            for snippet in line{
                if snippet.string.contains("/*") && snippet.type != .string && snippet.type != . debuggingInfo{
                    if snippet.string.hasPrefix("/*"){
                        let newStrings = snippet.string.components(separatedBy: "/*")
                        if newStrings.isEmpty{
                              newLine.append(CodeSnippet(string: "/* added in Line 103 ", type: .undefined))
                        }
                        for string in newStrings{
                            newLine.append(CodeSnippet(string: "DebuggingInfo: " + string, type: .debuggingInfo))
                            newLine.append(CodeSnippet(string: "/* added in Line 106 " + string , type: .undefined))
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "/*")
                        newLine.append(CodeSnippet(string: newStrings.first!, type: .undefined))
                        newStrings.removeFirst()
                        for string in newStrings{
                            newLine.append(CodeSnippet(string: "/* added in line 113" + string , type: .undefined))
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
                                newLine.append(CodeSnippet(string: string + "*/" , type: .undefined))
                            }
                        }
                        if snippet.string.components(separatedBy: "*/").count > 0{
                            newLine.append(CodeSnippet(string: snippet.string.hasSuffix("*/") ? snippet.string.components(separatedBy: "*/").last! + "*/" : snippet.string.components(separatedBy: "*/").last! , type: .undefined))
                        }
                    }else{
                        var newStrings = snippet.string.components(separatedBy: "*/")
                        newStrings.removeLast()
                        if !newStrings.isEmpty{
                            for string in newStrings {
                                newLine.append(CodeSnippet(string: string + "*/" , type: .undefined))
                            }
                        }
                        if snippet.string.components(separatedBy: "*/").count > 0{
                            newLine.append(CodeSnippet(string: snippet.string.hasSuffix("*/") ? snippet.string.components(separatedBy: "*/").last! + "*/" : snippet.string.components(separatedBy: "*/").last! , type: .undefined))
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
}
