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
    @State private var triggerUpdate = false
    
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    HStack{
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                ForEach(0..<max(30, sourceCode.components(separatedBy: "\n").count), id: \.self) { lineNumber in
                                    if lineNumber < sourceCode.components(separatedBy: "\n").count {
                                        Text("\(lineNumber + 1)")
                                            .frame(width: 30, height: geometry.size.height / CGFloat(max(30, sourceCode.components(separatedBy: "\n").count)))
                                            .foregroundColor(.black)
                                    } else {
                                        //Inserts a empty Text if sourceCode has less than 30 rows
                                        Text("")
                                            .frame(width: 30, height: geometry.size.height / CGFloat(max(30, sourceCode.components(separatedBy: "\n").count)))
                                    }
                                }
                                Spacer()
                            }
                        }.padding(.vertical)
                            .background(.white)
                            .frame(maxWidth: 30)
                            .padding(.vertical)
                        TextEditor(text: $sourceCode)
                            .padding()
                            .background(.white)
                            .frame(minHeight: 300)
                            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(LinearGradient(colors: [.backgroundMedium, .backgroundLight, .gray], startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth:2))
                            .padding([.vertical, .trailing])
                            .onChange(of: sourceCode){
                                
                                sourceCode = sourceCode.replacingOccurrences(of: "„", with: "\"")
                                sourceCode = sourceCode.replacingOccurrences(of: "“", with: "\"")
                                if sourceCode != mainScreenViewModel.loadSelectedFile()
                                    && !mainScreenViewModel.lastFileContainer.contains(where: {$0.url == mainScreenViewModel.selectedFile})
                                    && !mainScreenViewModel.selectedFile.absoluteString.isEmpty{
                                    mainScreenViewModel.lastFileContainer.append(FileRegisterItem(url: mainScreenViewModel.selectedFile, code: sourceCode, vm: mainScreenViewModel))
                                    showRegister = true
                                }
                                triggerUpdate.toggle()
                            }
                    }
                    
                }.frame(height: 320)
                    .padding()
                    .background(.transparentFull)
                CodeAnalyzerView(vm: CodeAnalyzerViewModel(sourceCode: sourceCode))
                    .frame(height: 420)
                    .padding()
                
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
