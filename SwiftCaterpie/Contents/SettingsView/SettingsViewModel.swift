//
//  SettingsViewModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import Foundation

class SettingsViewModel: ObservableObject{
    
    static let shared = SettingsViewModel()
    
    @Published var maxEmptyBreakLines = 2
    @Published var removeUnusedEmptyBreakeLines = true
}
