//
//  MainScreen.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct MainScreenView: View {
    
    @StateObject var vm = MainScreenViewModel()
    
    
    var body: some View {
        
        //Section for main working area
        VStack(spacing: 0){
            
            Header(vm: vm)
            ZStack{
                HStack(spacing:0){
                    if vm.fileExplorerIsVisible{
                        FileExplorer(isPresent: $vm.fileExplorerIsVisible, selectedFile: $vm.selectedFile)
                    }
                    WorkingArea(mainScreenViewModel: vm)
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
    MainScreenView()
}
