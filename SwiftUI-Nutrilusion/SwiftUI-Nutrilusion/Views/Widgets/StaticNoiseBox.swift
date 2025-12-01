//
//  StaticNoiseBox.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-10.
//


import SwiftUI

struct StaticNoiseBox: View {
    var cornerRadius: CGFloat = 10
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.white)
            .randomNoiseShader()
            .opacity(0.1)
    }
}
