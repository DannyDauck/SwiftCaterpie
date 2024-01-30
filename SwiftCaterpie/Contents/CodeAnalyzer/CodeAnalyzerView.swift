//
//  CodeAnalyzerView.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import SwiftUI


struct CodeAnalyzerView: View {
    
    
    @ObservedObject var vm: CodeAnalyzerViewModel
    
    
    var body: some View{
        
        ScrollView{
            VStack{
                ForEach(vm.codeItems , id: \.self){codeLine in
                    HStack{
                        ForEach(codeLine, id: \.self){codeItem in
                            AnyView(codeItem.viewItem).padding(0)
                        }
                        Spacer()
                    }
                }
            }.frame(minHeight: 410)
        }.padding(10)
            .frame(height: 400)
            .background(Color.black)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
    }
}




struct CodeAnalyzerView_Preview: PreviewProvider {
    static var previews: some View {
        CodeAnalyzerView(vm: CodeAnalyzerViewModel(sourceCode: "// ContentView.swift\n// CodeAnalyzer\n//\n// Created by Danny Dauck on 18.01.24.\n//\n\nimport SwiftUI\n\nstruct ContentView: View{\nVStack{//hier ist ein Fehler"))
    }
}

