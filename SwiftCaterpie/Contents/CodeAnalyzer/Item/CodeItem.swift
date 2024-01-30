//
//  CodeItem.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 29.01.24.
//
import Foundation
import SwiftUI

struct CodeItem: Identifiable, Hashable {
    
    var string: String
    var id: UUID
    var type: SnippetType
    var color: Color
    var brightness: Double
    var secondColor: Color
    var colorizeIndentation: Bool
    var blendedColor: Color{
        Color(NSColor.blend(color1: NSColor(hex: color.hexString()), intensity1: 1 - brightness, color2: NSColor(.white), intensity2: brightness))
                            }
    
    init(string: String, id: UUID, type: SnippetType, color: Color, brightness: Double, secondColor: Color = .white, colorizeIndentation: Bool = false) {
        self.string = string
        self.id = id
        self.type = type
        self.color = color
        self.brightness = brightness
        self.secondColor = secondColor
        self.colorizeIndentation = colorizeIndentation
    }
    
    init(_ codeSnippet: CodeSnippet, color: Color, brightness: Double, secondColor: Color = .white){
        self.string = codeSnippet.string
        self.id = codeSnippet.id
        self.type = codeSnippet.typ
        self.color = color
        self.brightness = brightness
        self.secondColor = secondColor
        self.colorizeIndentation = false
    }
    
    var viewItem: any View{
        get{
            switch self.type {
            case .debuggingInfo:
                return Text("DebugInfo:  " + string)
                    .foregroundStyle(.red)
                
            case .undefined:
                return Text(string)
                    .foregroundStyle(blendedColor)
            case .scopeStart:
                return Text(string)
                    .foregroundStyle(blendedColor)
            case .scopeEnd:
                return Text(string)
                    .foregroundStyle(blendedColor)
            case .comment:
                return Text(string)
                    .foregroundStyle(color)
            case .importType:
                return HStack{
                    Text("import ")
                        .foregroundStyle(color)
                    ZStack{
                        Text(string.replacingOccurrences(of: "import ", with: ""))
                            .foregroundStyle(.white)
                            .padding([.top,.leading],1.5)
                        Text(string.replacingOccurrences(of: "import ", with: ""))
                            .foregroundStyle(color)
                    }
                }
            case .varDeclaration:
                return Text(string)
            case .atDeclaration:
                return HStack{
                    Text("@")
                        .foregroundStyle(LinearGradient(colors: [color, secondColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    ZStack{
                        Text(string.dropFirst())
                            .foregroundStyle(.gray)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding([.top, .leading], 1)
                        Text(string.dropFirst())
                            .foregroundStyle(LinearGradient(colors: [color, secondColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                }
            case .hashDeclaration:
                return Text(string)
            case .warning:
                return Text(string)
                    .foregroundStyle(.red)
            case .string:
                return ZStack{
                    Text(string)
                        .foregroundStyle(.white)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding([.top, .leading], 1)
                    Text(string)
                        .foregroundStyle(LinearGradient(colors: [color, secondColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
            case .lineNumber:
                return Text(string)
                    .foregroundStyle(.gray)
                    .frame(width: 30)
            case .indentation:
                return Text(colorizeIndentation ? "|" + string:string)
                    .foregroundStyle(color.opacity(0.8))
            }
        }
    }
}



