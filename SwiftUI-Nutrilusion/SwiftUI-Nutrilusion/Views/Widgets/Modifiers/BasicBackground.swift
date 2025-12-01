//
//  BasicBackground.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-09.
//

import SwiftUI

struct BasicBackground<S: ShapeStyle>: ViewModifier {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var background: S
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
    func basicBackground(cornerRadius: CGFloat = 10, shadowRadius: CGFloat = 5, background: some ShapeStyle = .ultraThinMaterial, edges: Edge.Set = .bottom) -> some View {
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
