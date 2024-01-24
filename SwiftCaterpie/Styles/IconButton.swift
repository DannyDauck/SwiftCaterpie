//
//  File.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import Foundation
import SwiftUI

struct IconButton: ButtonStyle{
    var padding = 4.0
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .padding(padding)
            .tint(.black)
            .overlay(Circle().stroke(configuration.isPressed ? LinearGradient(colors: [Color.white, Color.gray], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.gray, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            .shadow(radius: configuration.isPressed ? 2:0)
    }
}
