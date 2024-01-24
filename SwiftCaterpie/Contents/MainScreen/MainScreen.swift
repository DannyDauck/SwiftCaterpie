//
//  MainScreen.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct MainScreen: View {
    
    @StateObject var vm = MainScreenModel()
    
    var body: some View {
        HStack{
            //Section for FileExplorer
            
            //Section for main working area
            VStack{
                Header(settingsIsVisible:{
                    vm.settingsIsVisible.toggle()
                })
            }
            
        }
    }
}

#Preview {
    MainScreen()
}
