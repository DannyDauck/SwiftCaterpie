//
//  SettingsViewModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject{
    
    /*
     
     Alle Color sind über die Hexwerte initialisiert damit Color.cgColor.component RGB Wert enthält,  um die Farbe später in eine
     NSColor umzuwandeln
     
      #00FF00 -> Color.green
      #FFFF00 -> Color.yellow
      #FFA500 -> Color.orange
      #FF0000 -> Color.red
      #4B0082 -> Color.indigo
      #0000FF -> Color.blue
      #00FFFF -> Color.cyan
      #FFC0CB -> pink
      #66AA66 -> gras green

     */
    
    static let shared = SettingsViewModel()
    
    @Published var maxEmptyBreakLines = 2
    @Published var removeUnusedEmptyBreakeLines = true
    @Published var colorArray = [Color(hex: "#00FF00"), Color(hex: "#FFFF00"), Color(hex: "#FFA500"), Color(hex: "#FF0000"), Color(hex: "#480082"), Color(hex: "#0000FF"), Color(hex: "#00FFFF")]
    @Published var brigthnessSteps = 5
    @Published var importTypeColor = Color(hex: "#00FF00")
    @Published var commentColor = Color(hex: "#66AA66")
    @Published var stringHighlight = Color(hex: "#0000FF")
    @Published var atDeclarationHighlight = Color(hex: "#FFC0CB")
    @Published var colorizeIndentation = false
    private let minBrightness: Double = 0.2
    private let lightupIntens: Double = 1.0
    
    
    func getScopeColor(_ color: Int) -> Color{
        return colorArray[(colorArray.count + color) % colorArray.count]
    }
    func getBrightness(_ int: Int) -> Double{
        let index = (int + brigthnessSteps) % brigthnessSteps
        let stepWidth = (Double(lightupIntens) - minBrightness) / Double(brigthnessSteps)
        return stepWidth * Double(index)
    }
}
