//
//  FileExplorer.swift
//  SwiftCaterpie
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct FileExplorer: View {
    
    @Binding var isPresent: Bool
    @Binding var selectedFile: URL
    @State private var droppedFiles: [URL] = []
    
    
    var body: some View {
        ZStack{
            //Background
            Rectangle().fill(.transparentHalf)
            
            VStack(spacing: 0){
                
                //Header
                HStack{
                    Button(action: {
                        isPresent.toggle()
                    }){
                        Image(systemName: "xmark.circle")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .foregroundStyle(.white)
                    }.buttonStyle(IconButton(padding: 0))
                        .background(LinearGradient(colors: [.backgroundMedium, .highlightOne], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .focusable(false)
                        .padding(.leading,10)
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                    Text("File Explorer")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.gray)
                        .padding(.leading, 5)
                        .frame(width: 200)
                    
                    Spacer()
                   
                }.padding([.leading, .trailing], 5)
                    .padding([.bottom, .top], 0)
                    .background(.backgroundMedium.opacity(0.8))
                
                //drag n drop area
                
                ScrollView([.horizontal,.vertical]){
                    if droppedFiles.isEmpty {
                        Spacer()
                        Text("Drop a Swift file or a\nproject folder")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Spacer()
                    } else {
                        ForEach(droppedFiles, id: \.self) { url in
                                DroppedItem(droppedFileURL: url, selectedFile: $selectedFile, removeFile: {droppedFiles.removeAll(where: { $0 == url})}, isFolder: isDirectory(url: url))
                            
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 230)
            .onDrop(of: ["public.file-url"], isTargeted: nil) { providerList in
                return self.dropDelegate(providerList: providerList)
            }
            
        }.frame(width: 230)
    }
    private func dropDelegate(providerList: [NSItemProvider]) -> Bool {
        for provider in providerList {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url") { (urlData, error) in
                    if let urlData = urlData as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        DispatchQueue.main.async {
                            droppedFiles.append(url)
                        }
                    }
                }
            }
        }
        return true
    }
    
    private func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
}

#Preview {
    FileExplorer(isPresent: .constant(true),selectedFile:  .constant(URL(fileURLWithPath: " ")))
}
