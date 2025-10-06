//
//  SwipeableRow.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-25.
//


import SwiftUI

// note: this exists because the built-in .swipeActions modifier only works in Lists which we don't use.
struct SwipeableRow<Content: View>: View {
    var maxSwipeDistance: CGFloat = 150
    var minRequiredSwipeDistance: CGFloat = 80
    
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content
    
    @State private var offset: CGFloat = 0
    
    private var revealWidth: CGFloat {
        min(offset, maxSwipeDistance)
    }
    
    private var deleteTextOpacity: Double {
        Double(revealWidth / maxSwipeDistance)
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.clear
                .overlay(
                    HStack {
                        Spacer()
                        
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                            .opacity(deleteTextOpacity)
                            .padding(.trailing, 20)
                    },
                    alignment: .trailing
                )
                .mask(
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .frame(width: revealWidth)
                    }
                )
            
            content()
                .offset(x: -offset)
                .highPriorityGesture(
                    // future ref: minDistance was used to tweak sweet spot between
                    //   scrollview vertical drag and row deletion horizontal drag
                    DragGesture(minimumDistance: 25, coordinateSpace: .local)
                        .onChanged { value in
                            if abs(value.translation.width) > abs(value.translation.height) && value.translation.width < 0 {
                                offset = min(-value.translation.width, maxSwipeDistance)
                            }
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > abs(value.translation.height) && value.translation.width < -minRequiredSwipeDistance {
                                withAnimation(.spring()) {
                                    onDelete()
                                }
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
