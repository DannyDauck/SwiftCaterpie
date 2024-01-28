//
//  ColorManager.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import Foundation
import SwiftUI

struct ColorManager{
    
    
    private var colorMatrix: [[Color]] = [[]]
    @State private var brightness = 0
    @State private var colorIndex = 0
    var color: Color{
        return colorMatrix[(brightness+6)%5][(colorIndex+8)%7]
    }
    var importColor = Color.yellow
    var commentColor = Color.white
    
    init() {
        colorMatrix = generateColorMatrix()
    }
    
    
    func nextColor(){
        colorIndex += 1
    }
    func previouseColor(){
        colorIndex -= 1
    }
    func raiseBrightness(){
        brightness += 1
    }
    func lowerBrightness(){
        brightness -= 1
    }
    
    //returns spaces for correct indentation depending on the value of colorIndex
    func getIndentation() -> String{
        return colorIndex == 0 ? "":String(repeating: "    ", count: colorIndex)
    }
    
    /*generates a color matrix as  array of arrays
     
     -> color
     |
     v
     brightness
     
     */
    
    
    private func generateColorMatrix() -> [[Color]] {
        let numberOfColors = 5
        var colors: [[Color]] = [[]]
        
        //plus one is hardcode so it starts with
        for index in 1..<(numberOfColors+1) {
            let factor = Double(index) / Double(numberOfColors - 3)
            var rowColors: [Color] = []
            
            for hue in stride(from: 0.0, through: 0.9, by: 0.15) {
                let color = Color(hue: hue, saturation: 1.0, brightness: factor)
                rowColors.append(color)
            }
            
            colors.append(rowColors)
        }
        
        return colors
    }
    
}
