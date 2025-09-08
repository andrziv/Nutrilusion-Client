//
//  LazyVScroll.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-08.
//

import SwiftUI

struct LazyVScroll<Item: Identifiable, Content: View>: View {
    private let spacing: CGFloat
    private let scrollView: AnyView
    
    // for bindings
    init(items: Binding<[Item]>,
         spacing: CGFloat = 10,
         @ViewBuilder content: @escaping (Binding<Item>) -> Content) {
        self.spacing = spacing
        self.scrollView = AnyView(
            ScrollView {
                LazyVStack(spacing: spacing) {
                    ForEach(items) { $item in
                        content($item)
                    }
                }
            }
        )
    }
    
    init(items: [Item],
         spacing: CGFloat = 10,
         @ViewBuilder content: @escaping (Item) -> Content) {
        self.spacing = spacing
        self.scrollView = AnyView(
            ScrollView {
                LazyVStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                    }
                }
            }
        )
    }
    
    var body: some View {
        scrollView
    }
}

