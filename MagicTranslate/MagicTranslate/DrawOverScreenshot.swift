//
//  DrawOverScreenshot.swift
//  MagicTranslate
//
//  Created by Matt Novoselov on 17/05/24.
//

import SwiftUI

struct DrawOverScreenshot: View {
    
    @State private var startLocation = CGPoint.zero
    @State private var currentLocation = CGPoint.zero
    
    var body: some View {
        PreviewImage()
            .overlay{
                Color.black
                    .opacity(0.4)
                
                GeometryReader { proxy in
                    let rect = CGRect(
                        x: min(startLocation.x, currentLocation.x),
                        y: min(startLocation.y, currentLocation.y),
                        width: abs(currentLocation.x - startLocation.x),
                        height: abs(currentLocation.y - startLocation.y)
                    )
                    
                    PreviewImage()
                        .mask{
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }
                        .overlay{
                            SelectionBoxDebugInfo(debugEnabled: true, rect: rect)
                        }
                }
            }
            .gesture(dragGesture())
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                startLocation = gesture.startLocation
                currentLocation = gesture.location
            }
    }
}

struct PreviewImage: View {
    var body: some View {
        Image(.appPlaceholder)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct SelectionBoxDebugInfo: View {
    let debugEnabled: Bool
    var rect: CGRect
    
    var body: some View {
        if debugEnabled{
            Group{
                VStack(alignment: .leading){
                    Text("x: \(Int(rect.minX))")
                    Text("y: \(Int(rect.minY))")
                    Text("width: \(Int(rect.width))")
                    Text("height: \(Int(rect.height))")
                }
            }
            .foregroundStyle(.green)
            .fontWeight(.medium)
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    DrawOverScreenshot()
}
