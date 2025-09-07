//
//  BottomTrailing.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//

import SwiftUI

struct BottomTrailing<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content
            }
        }
    }
}
