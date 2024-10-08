//
//  ImagePickerView.swift
//  MagicTranslate
//
//  Created by Matt Novoselov on 03/06/24.
//

import SwiftUI

struct ImagePickerView: View {
    
    @Binding var selectedImages: [NSImage]
    @Binding var localizationItem: LocalizationItem
    var localizationKey: String
    @State private var selectedIndex: Int?
    
    // Adapt to different screen sizes
    // Fill remaining space even if column rows are specified as two
    private let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.gray)
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                    handleOnDrop(providers: providers)
                }
            
            if selectedImages.isEmpty {
                VStack{
                    Text("+")
                        .font(.largeTitle)
                        .fontWeight(.light)
                    Text("Drag&Drop images here")
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            SingleImagePreview(selectedImages: $selectedImages, localizationItem: $localizationItem, localizationKey: localizationKey, selectedImage: selectedImages[index], selectedIndex: $selectedIndex, index: index)
                        }
                    }
                    .padding(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private func handleOnDrop(providers:[NSItemProvider]) -> Bool {
        var handled = false
        let dispatchGroup = DispatchGroup()
        
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                dispatchGroup.enter()
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, error in
                    if let data = data as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil),
                       url.isFileURL,
                       let imageData = try? Data(contentsOf: url),
                       let nsImage = NSImage(data: imageData) {
                        
                        DispatchQueue.main.async {
                            selectedImages.append(nsImage)
                        }
                        handled = true
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if handled {
                print("All images are successful processed.")
            }
        }
        
        return handled
    }
}


struct SingleImagePreview: View {
    
    @Binding var selectedImages: [NSImage]
    @Binding var localizationItem: LocalizationItem
    var localizationKey: String
    var selectedImage: NSImage
    @Binding var selectedIndex: Int?
    var index: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            // Add
            Button(action: {
                withAnimation {
                    localizationItem.screenshot = convertToPNGData(nsImage: selectedImage)
                    selectedIndex = index
                }
            }) {
                Rectangle()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(.clear)
                    .overlay{
                        if selectedImages.contains(selectedImage) {
                            // Use unwrappedImage safely here
                            Image(nsImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                            // MARK:
                                .overlay{
                                    // Dimming effect
                                    Color.black
                                        .opacity((index == selectedIndex) ? 0 : 0.5)
                                }
                        }
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .help(Text("Select image"))
            
            // Delete
            Button(action: {
                withAnimation {
                    if selectedImages.contains(selectedImage) {
                        if localizationItem.screenshot == convertToPNGData(nsImage: selectedImage){
                            localizationItem.screenshot = nil
                        }
                        
                        selectedImages.remove(at: index)
                    }
                }
            }) {
                Image(systemName: "trash")
                    .padding(.all, 5)
                    .foregroundColor(.gray)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 5))
            }
            .buttonStyle(PlainButtonStyle())
            .help(Text("Delete image"))
            
        }
    }
    
}
