//
//  MainScreenModel.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import Foundation


@MainActor
class MainScreenViewModel: ObservableObject{
    
    @Published var settingsIsVisible: Bool = false
    @Published var fileExplorerIsVisible = true
    @Published var selectedFile: URL = URL(fileURLWithPath: "empty")
    @Published var lastFileContainer: [FileRegisterItem] = []
    
    func loadSelectedFile()->String{
        if lastFileContainer.contains(where: {
            $0.self.url == selectedFile
        }){
            return lastFileContainer.filter{
                $0.self.url == selectedFile
            }.first!.code
        } else {
            do{
                let code = try String(contentsOf: selectedFile)
                return code
            }catch{
                print("something went wrong while loading code")
                return "Could not load this file"
            }
        }
    }
}
