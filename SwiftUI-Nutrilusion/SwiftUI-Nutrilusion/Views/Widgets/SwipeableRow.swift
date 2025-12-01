//
//  SwipeableRow.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-25.
//


import SwiftUI


// note: this exists because the built-in .swipeActions modifier only works in Lists which we don't use.
struct SwipeableRow<Content: View>: View {
    var maxSwipeDistance: CGFloat = 150
    var minRequiredSwipeDistance: CGFloat = 80
    
    var onDelete: (() -> Void)? = nil
    var onRightSwipe: (() -> Void)? = nil
    
    @ViewBuilder let content: () -> Content
    
    @State private var offset: CGFloat = 0
    
    private var revealWidth: CGFloat {
        min(offset, maxSwipeDistance)
    }
    
    private var actionOpacity: Double {
        Double(revealWidth / maxSwipeDistance)
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                if onRightSwipe != nil {
                    Label("Edit", systemImage: "pencil")
                        .foregroundColor(.blue)
                        .opacity(actionOpacity)
                        .labelStyle(ReverseLabelStyle())
                }
                
                Spacer()
                
                if onDelete != nil {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                        .opacity(-actionOpacity)
                }
            }
            
            content()
                .offset(x: offset)
                .highPriorityGesture(
                    // future ref: minDistance was used to tweak sweet spot between
                    //   scrollview vertical drag and row deletion horizontal drag
                    DragGesture(minimumDistance: 25, coordinateSpace: .local)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else {
                                return
                            }
                            
                            if value.translation.width < 0, onDelete != nil {
                                offset = max(value.translation.width, -maxSwipeDistance)
                            } else if value.translation.width > 0, onRightSwipe != nil {
                                offset = min(value.translation.width, maxSwipeDistance)
                            }
                        }
                        .onEnded { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else {
                                offset = 0
                                return
                            }
                            
                            if value.translation.width < -minRequiredSwipeDistance, onDelete != nil {
                                withAnimation(.spring()) {
                                    onDelete?()
                                }
                            } else if value.translation.width > minRequiredSwipeDistance, onRightSwipe != nil {
                                withAnimation(.spring()) {
                                    onRightSwipe?()
                                }
                            }
                            
                            offset = 0
                        }
                )
        }
        .animation(.spring(), value: offset)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
