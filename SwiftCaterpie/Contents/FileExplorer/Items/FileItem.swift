//
//  SwiftUIView.swift
//  CodeAnalyzer
//
//  Created by Danny Dauck on 24.01.24.
//

import SwiftUI

struct FileItem: View {
    
    let fileURL: URL
    @Binding var selectedFile: URL
    
    private var fileIcon: Image {
           
           switch fileURL.pathExtension.lowercased() {
           case "swift":
               return Image(.swiftIcon)
                   .resizable()
                
           case "json":
               return Image(.jsonIcon)
                   .resizable()
                   
           case "plist":
               return Image(systemName: "list.bullet.rectangle")
               
           case "png": return Image(systemName: "photo.on.rectangle.angled")
               
           case "jpeg": return Image(systemName: "photo.on.rectangle.angled")
           // Space for other extensions
               
               
           default:
               return Image(systemName: "doc")
           }
       }
    
    
    var body: some View {
        HStack{
            fileIcon.frame(width: 20, height: 20)
            Text(fileURL.deletingPathExtension().lastPathComponent)
                .foregroundStyle(.black)
                .fontWeight(fileURL.pathExtension.lowercased() == "swift" ? .bold : .regular)
            if fileURL.pathExtension.lowercased() == "png"{
                Text("PNG")
                    .foregroundStyle(.orange)
                    .border(.orange)
            }else if fileURL.pathExtension.lowercased() == "jpeg"{
                Text("JPEG").foregroundStyle(.blue).border(.blue)
            }
            Spacer()
        }.padding(.leading, 8.0)
            .padding([.top, .bottom],2)
            .padding(.trailing, 8)
            .background(selectedFile == fileURL ? .highlightOne: .transparentHalf)
            .onTapGesture {
                selectedFile = fileURL
            }
        
    }
    
    
    private func loadCode(){
        
    }
}


 #Preview {
     FileItem(fileURL:  URL(fileURLWithPath: "/Users/dannydauck/Documents/GitHub/CodeAnalyzer/CodeAnalyzer/ItemViews/FileItem.swift"), selectedFile: .constant(URL(fileURLWithPath: " ")))
 }

