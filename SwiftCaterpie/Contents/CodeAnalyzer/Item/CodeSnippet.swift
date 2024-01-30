//
//  CodeSnippet.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//
// for the first analyze, this is not a view, it just contains the informnation what was recognized by the CodeAnalyzerViewModel's logic.

import Foundation

struct CodeSnippet: Identifiable, Hashable{
    var string: String
    var typ: SnippetType
    var id = UUID()
    
    func cloneSnippetWithNewType(_ newType: SnippetType)->CodeSnippet{
        return CodeSnippet(string: self.string, typ: newType, id: self.id)
    }
    func replaceString(_ new: String)->CodeSnippet{
        return CodeSnippet(string: new , typ: self.typ, id: self.id)
    }
}
