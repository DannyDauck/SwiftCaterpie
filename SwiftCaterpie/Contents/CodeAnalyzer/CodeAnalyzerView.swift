//
//  CodeAnalyzerView.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import SwiftUI



struct CodeAnalyzerView: View {
    
    @ObservedObject var vm: CodeAnalyzerViewModel
    
    
    var body: some View {
        ScrollView([.vertical, .horizontal]){
            VStack {
                ForEach(vm.analyzedCode, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { codeSnippet in
                            if codeSnippet.type == .comment {
                                Text(codeSnippet.string)
                                    .foregroundStyle(.green)
                            }else if codeSnippet.type == .string {
                                Text(codeSnippet.string)
                                    .foregroundStyle(.blue)
                            }else if codeSnippet.type == .lineNumber{
                                Text(codeSnippet.string)
                                    .foregroundStyle(.gray)
                                    .frame(width: 30)
                            }else{
                                Text(codeSnippet.string)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
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
