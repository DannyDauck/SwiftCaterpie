//
//  SnippetType.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

//used to analyze the code and colorize it later by type

import Foundation

enum SnippetType: CaseIterable{
    //TODO remove debbuging Info later
    case debuggingInfo, undefined, scopeStart, scopeEnd, comment, importType, varDeclaration, atDeclaration, hashDeclaration, warning, string, lineNumber, indentation
}
