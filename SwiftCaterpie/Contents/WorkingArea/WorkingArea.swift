//
//  WorkingArea.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import SwiftUI

struct WorkingArea: View {
    @ObservedObject var mainScreenViewModel: MainScreenViewModel
    @State var sourceCode: String = ""
    @State var showRegister = false
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    TextEditor(text: $sourceCode)
                        .padding()
                        .background(.white)
                        .frame(minHeight: 400)
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(LinearGradient(colors: [.backgroundMedium, .backgroundLight, .gray], startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth:2))
                        .padding()
                        .onChange(of: sourceCode){
                            if sourceCode != mainScreenViewModel.loadSelectedFile()
                                && !mainScreenViewModel.lastFileContainer.contains(where: {$0.url == mainScreenViewModel.selectedFile})
                                && !mainScreenViewModel.selectedFile.absoluteString.isEmpty{
                                mainScreenViewModel.lastFileContainer.append(FileRegisterItem(url: mainScreenViewModel.selectedFile, code: sourceCode, vm: mainScreenViewModel))
                                showRegister = true
                            }
                            
                        }
                    
                }.frame(height: 420)
                    .padding()
                    .background(.transparentFull)
                Spacer()
            }.background(LinearGradient(colors: [.gray, .backgroundLight,.backgroundMedium], startPoint: .bottomLeading, endPoint: .topTrailing))
                .onChange(of: mainScreenViewModel.selectedFile){
                    sourceCode = mainScreenViewModel.loadSelectedFile()
                }
            VStack(spacing: 0){
                if !mainScreenViewModel.lastFileContainer.isEmpty{
                    HStack{
                        ForEach(mainScreenViewModel.lastFileContainer, id: \.self.url){
                            $0
                        }
                        Spacer()
                    }.background(.transparentFull)
                }
                Spacer()
            }
            
        }
    }
}


#Preview {
    WorkingArea(mainScreenViewModel: MainScreenViewModel())
}
