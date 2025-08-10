//
//  BasicBackground.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//

import SwiftUI

struct BasicBackground: ViewModifier {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var background: Material
    var edges: Edge.Set
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: shadowRadius)
            .ignoresSafeArea(edges: edges)
    }
}

extension View {
    func basicBackground(cornerRadius: CGFloat = 10, shadowRadius: CGFloat = 5, background: Material = .ultraThinMaterial, edges: Edge.Set = .bottom) -> some View {
        self.modifier(
            BasicBackground(
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius,
                background: background,
                edges: edges
            )
        )
    }
}
