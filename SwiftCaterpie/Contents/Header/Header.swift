//
//  SwiftUIView.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct Header: View {
    
    @ObservedObject var vm: MainScreenViewModel

    
    var body: some View {
        HStack{
            if !vm.fileExplorerIsVisible {Button(action: {
                vm.fileExplorerIsVisible.toggle()
            }, label: {
                ZStack{
                    Image(systemName: "square.leftthird.inset.filled")
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient(colors: [.highlightOne, .highlightTwo], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .padding([.top,.leading],4)
                    Image(systemName: "square.leftthird.inset.filled")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }).buttonStyle(IconButton())
                    .padding(.trailing)
            }
            
            ZStack{
                Text("Swift Caterpie")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding([.top, .leading], 4)
                    .foregroundStyle(LinearGradient(colors: [.highlightOne, .highlightTwo, .highlightThree], startPoint: .bottomLeading, endPoint: .topTrailing))
                Text("Swift Caterpie")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.white)
            }
            ZStack{
                Image(systemName: "waveform.path.ecg")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding([.top, .leading], 4)
                    .foregroundStyle(LinearGradient(colors: [.highlightOne, .highlightTwo, .highlightThree], startPoint: .bottomLeading, endPoint: .topTrailing))
                Image(systemName: "waveform.path.ecg")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            Spacer()
            Button(action: {
                vm.settingsIsVisible.toggle()
            }, label: {
                ZStack{
                    Image(systemName: "gearshape")
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient(colors: [.highlightOne, .highlightTwo], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .padding([.top,.leading],4)
                    Image(systemName: "gearshape")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }).buttonStyle(IconButton())
                .focusable(false)
        }.padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
        .background(.black)
    }
}

#Preview {
    Header(vm: MainScreenViewModel())
}
