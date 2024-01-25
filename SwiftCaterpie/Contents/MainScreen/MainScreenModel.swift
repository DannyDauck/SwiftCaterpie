//
//  MainScreenModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import Foundation


@MainActor
class MainScreenModel: ObservableObject{
    
    @Published var settingsIsVisible: Bool = false
    @Published var fileExplorerIsVisible = true
    @Published var selectedFile: URL = URL(fileURLWithPath: "empty")
}
