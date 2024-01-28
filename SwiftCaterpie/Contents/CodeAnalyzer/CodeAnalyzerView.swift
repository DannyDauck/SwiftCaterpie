//
//  CodeAnalyzerView.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import SwiftUI



struct CodeAnalyzerView: View {
    
    
    @ObservedObject var vm: CodeAnalyzerViewModel
    // private var cm: ColorManager = ColorManager()
    
    init(vm: CodeAnalyzerViewModel) {
        self.vm = vm
        //self.cm = ColorManager()
    }
    var body: some View{
        ScrollView(.vertical){
            
            VStack(alignment: .leading){
                ForEach(vm.analyzedCode, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { codeSnippet in
                            
                            if codeSnippet.type == .lineNumber{
                                Text(codeSnippet.string)
                                    .foregroundStyle(.gray)
                                Text(.white)
                            }
                            
                            else if codeSnippet.type == .scopeBeginnings {
                                Text(codeSnippet.string)
                                    .foregroundStyle(.green)
                            }
                            else if codeSnippet.type == .scopeEndings {
                                Text(codeSnippet.string)
                                    .foregroundStyle(.green)
                            }

                            else if codeSnippet.type == .comment{
                                Text(codeSnippet.string)
                                    .foregroundStyle(.green)
                            }
                            else if codeSnippet.type == .string{
                                Text(codeSnippet.string)
                                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .bottomLeading, endPoint: .topTrailing))
                            }
                            else {
                                Text(codeSnippet.string)
                                    .foregroundStyle(.indigo)
                            }
                            
                        }
                    }
                }
            }
        }.padding(10)
            .frame(height: 400)
            .background(Color.black)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
    }
    
}


#Preview {
    CodeAnalyzerView(vm: CodeAnalyzerViewModel(sourceCode: "//  ContentView.swift\n// CodeAnalyzer\n//\n//  Created by Danny Dauck on 18.01.24.\n//\n\nimport SwiftUI\n\nstruct ContentView: View{\nVStack{//hier ist ein Fehler"))
}

