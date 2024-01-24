//
//  SettingsView.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct SettingsView: View {
    
    @State var docksExpand = true
    
    var body: some View{
        VStack{
            HStack{
                Text("Settings")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding(.leading, 10)
                Spacer()
            }
            
            Divider()
            
            Section(isExpanded: $docksExpand, content: {
                
                // P L A C E H O L D E R
                Image(systemName: "globe")}
            ){
                HStack{
                    Button(action: {
                        docksExpand.toggle()
                    }){
                        Image(systemName: docksExpand ?  "chevron.down" : "chevron.right")
                    }.padding(.leading, 8)
                        .buttonStyle(IconButton())
                        .focusable(false)
                    Text("Docks")
                    Spacer()
                }
            }
            
            Section(isExpanded: $docksExpand, content: {
                
                // P L A C E H O L D E R
                Image(systemName: "globe")}
            ){
                HStack{
                    Button(action: {
                        docksExpand.toggle()
                    }){
                        Image(systemName: docksExpand ?  "chevron.down" : "chevron.right")
                    }.padding(.leading, 8)
                        .buttonStyle(IconButton())
                        .focusable(false)
                    Text("Appereance")
                    Spacer()
                }
            }
            
            
        }.foregroundStyle(.white)
            .frame(width: 250)
            .padding([.bottom],10)
            .background(.black)
    }
}

#Preview {
    SettingsView()
}
