//
//  SwappingVHStack.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-11.
//


import SwiftUI

struct SwappingVHStack<Content: View>: View {
    let vSpacing: CGFloat
    let hSpacing: CGFloat
    let hAlignment: VerticalAlignment
    let vAlignment: HorizontalAlignment
    let useHStack: Bool
    let content: Content
    
    init(vSpacing: CGFloat = 10, hSpacing: CGFloat = 10,
         hAlignment: VerticalAlignment = .top, vAlignment: HorizontalAlignment = .leading,
         useHStack: Bool = false,
         @ViewBuilder content: () -> Content) {
        self.vSpacing = vSpacing
        self.hSpacing = hSpacing
        
        self.hAlignment = hAlignment
        self.vAlignment = vAlignment
        
        self.useHStack = useHStack
        self.content = content()
    }
    
    var body: some View {
        if useHStack {
            HStack(alignment: hAlignment, spacing: hSpacing) {
                content
            }
        } else {
            VStack(alignment: vAlignment, spacing: vSpacing) {
                content
            }
        }
    }
}