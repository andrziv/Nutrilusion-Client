//
//  StaticNoiseBox.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-10.
//


import SwiftUI

struct StaticNoiseBox: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .randomNoiseShader()
            .opacity(0.1)
            .background(RoundedRectangle(cornerRadius: 10)
                .stroke(.clear, lineWidth: 1))
    }
}