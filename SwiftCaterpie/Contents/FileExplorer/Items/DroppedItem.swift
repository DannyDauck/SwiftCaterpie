//
//  DroppedItem.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 25.01.24.
//

import SwiftUI

struct DroppedItem: View {
    
    let droppedFileURL: URL
    @Binding var selectedFile: URL
    let removeFile: ()->()
    let isFolder: Bool
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Button(action: {
                    removeFile()
                }){
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .background(LinearGradient(colors: [.backgroundMedium, .highlightOne], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .foregroundStyle(.white)
                }.buttonStyle(IconButton(padding: 0))
                Text(droppedFileURL.lastPathComponent)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Spacer()
                    
            }.padding(.horizontal, 5)
                .background(.backgroundMedium.opacity(0.5))
            if isFolder{
                FolderItem(folderURL: droppedFileURL, leftOffset: 0.0, selectedFile: $selectedFile)
            }else{
                FileItem(fileURL: droppedFileURL, selectedFile: $selectedFile)
            }
            Divider()
        }
    }
}

#Preview {
    DroppedItem(droppedFileURL: URL(fileURLWithPath: "/Users/dannydauck/Documents/GitHub/CodeAnalyzer/CodeAnalyzer"), selectedFile: .constant(URL(fileURLWithPath: "empty")), removeFile: {}, isFolder: true)
}
