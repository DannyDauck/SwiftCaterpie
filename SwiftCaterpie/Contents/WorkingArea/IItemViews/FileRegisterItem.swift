//
//  FileRegisterItem.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 27.01.24.
//

import SwiftUI

struct FileRegisterItem: View {
    
    let url: URL
    @State var code: String
    @ObservedObject var vm: MainScreenViewModel
    
    var body: some View{
        HStack{
            Image(systemName: "xmark.circle")
                .font(.title2)
                .onTapGesture {
                    vm.lastFileContainer.removeAll(where: {
                        $0.url == url
                    })
                    vm.selectedFile = vm.lastFileContainer.last?.url ?? URL(fileURLWithPath: "")
                }
            
            Image(url.pathExtension == "swift" ? .swiftIcon:.jsonIcon)
                .resizable()
                .frame(width: 20,height: 20)
            Text(url.deletingPathExtension().lastPathComponent)
                .font(.title2)
                .fontWeight(vm.selectedFile == url ? .bold:.regular)
                .foregroundStyle(vm.selectedFile == url ? .white: .black)
        }
        .padding(2)
        .background(vm.selectedFile == url ? .highlightOne:.gray)
        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black, lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/))
        .padding(.bottom, 3)
        .onTapGesture {
            vm.selectedFile = url
        }
    }
}

#Preview {
    FileRegisterItem(url: URL(fileURLWithPath: "/Users/dannydauck/Documents/GitHub/SwiftCaterpie/SwiftCaterpie/Contents/WorkingArea/IItemViews/FileRegisterItem.swift"), code: "Hello", vm: MainScreenViewModel())
}
