//
//  BreathingTextBoxView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-10.
//


import SwiftUI

struct BreathingTextBoxView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .padding(4)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray)
                .opacity(0.2))
            .padding(4)
            .phaseAnimator([1.0, 0]) { content, phase in
                content.opacity(phase)
            } animation: { _ in
                    .easeInOut(duration: 5.0)
            }
    }
}