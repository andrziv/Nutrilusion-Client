//
//  SwipeableRow.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-25.
//


import SwiftUI

struct SwipeableRow<Content: View>: View {
    var maxSwipeDistance: CGFloat = 150
    var minRequiredSwipeDistance: CGFloat = 80
    
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .padding(.trailing, 20)
            }
            
            content()
                .offset(x: -offset)
                .gesture(
                    // future ref: minDistance was used to tweak sweet spot between
                    //   scrollview vertical drag and row deletion horizontal drag
                    DragGesture(minimumDistance: 18, coordinateSpace: .local)
                        .onChanged { value in
                            if value.translation.width < 0 { // left swipe
                                offset = min(-value.translation.width, maxSwipeDistance)
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < -minRequiredSwipeDistance {
                                withAnimation(.spring()) { onDelete() }
                            } else {
                                offset = 0
                            }
                        }
                )
        }
        .animation(.spring(), value: offset)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
