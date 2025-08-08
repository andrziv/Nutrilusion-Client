//
//  LazyVScroll.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-08.
//

import SwiftUI

struct LazyVScroll<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content
    var spacing: CGFloat = 10
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                }
            }
        }
    }
}
