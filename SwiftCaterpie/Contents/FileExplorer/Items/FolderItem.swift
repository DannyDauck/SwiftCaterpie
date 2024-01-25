//
//  FolderItem.swift
//  CodeAnalyzer
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct FolderItem: View{
    
    let folderURL: URL
    let leftOffset: Double
    @Binding var selectedFile: URL
    
    @State private var isOpen = false
    @State private var folderContent: [URL] = []
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    openFolder()
                    isOpen.toggle()
                }){
                    Image(systemName:isOpen ? "chevron.down":"chevron.right")
                }.buttonStyle(IconButton())
                    .focusable(false)
                    .padding(.trailing, 5)
                    .padding(.leading, 8.0 + leftOffset)
                Image(systemName: folderURL.lastPathComponent == "Assets.xcassets" ? "archivebox":"folder.fill")
                    .foregroundStyle(folderURL.lastPathComponent == "Assets.xcassets" ? .highlightOne:.yellow)
                    .overlay(Image(systemName: folderURL.lastPathComponent == "Assets.xcassets" ? "archivebox":  "folder").padding([.trailing,.bottom],folderURL.lastPathComponent == "Assets.xcassets" ? 2 : 0))
                Text(folderURL.lastPathComponent == "Assets.xcassets" ?  "ASSETS":folderURL.lastPathComponent)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                Spacer()
                
            }.frame(width: 200)
                .padding(2)
                .padding(.leading, 10)
            if isOpen{
                    ForEach(Array(folderContent.enumerated()), id: \.element) { index, content in
                        if isDirectory(url: content) {
                            FolderItem(folderURL: content, leftOffset: (leftOffset + 20.0), selectedFile: $selectedFile).id(index)
                        // entitlments-Datei ausblenden
                        } else if !content.lastPathComponent.contains(".entitlements"){
                            
                            FileItem(fileURL: content, selectedFile: $selectedFile).id(index)
                                .padding(.leading, leftOffset + 40.0)
                        }
                }
            }
        }
    }
    private func openFolder(){
        
        do {
            //read URL-Path and write the contents intto folderContent
            folderContent = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            } catch {
                    print("Something went wrong while loading the folder: \(error.localizedDescription)")
            }
    }
    private func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}

#Preview {
    FolderItem(folderURL: URL(fileURLWithPath: "/Users/dannydauck/Documents/GitHub/CodeAnalyzer/CodeAnalyzer"), leftOffset: 0.0, selectedFile: .constant(URL(fileURLWithPath: " ")))
}
