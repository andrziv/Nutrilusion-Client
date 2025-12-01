//
//  BreathingTextBoxView.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-10.
//


import SwiftUI

struct BreathingTextBoxView: View {
    var text: String
    var textColour: Color = .secondaryText
    var colour: Color = .primaryComplement
    var cornerRadius: CGFloat = 10
    
    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(textColour)
            .padding(4)
            .background(RoundedRectangle(cornerRadius: cornerRadius)
                .fill(colour)
                .opacity(0.2))
            .padding(4)
            .phaseAnimator([1.0, 0]) { content, phase in
                content.opacity(phase)
            } animation: { _ in
                    .easeInOut(duration: 5.0)
            }
    }
}
