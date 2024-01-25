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
        
        //Section for main working area
        VStack(spacing: 0){
            
            Header(settingsIsVisible:{
                vm.settingsIsVisible.toggle()
            })
            ZStack{
                HStack{
                    FileExplorer(isPresent: $vm.settingsIsVisible, selectedFile: $vm.selectedFile)
                    Spacer()
                }
                if vm.settingsIsVisible{ HStack{
                    Spacer()
                    VStack{
                        SettingsView()
                        Spacer()
                    }
                }
                }
            }
        }.background(Image(.excampleBg)
            .resizable().scaledToFill())
        .presentationCornerRadius(15)
    }
}



#Preview {
    MainScreen()
}
