//
//  ImagedButton.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct ImagedButton: View {
    let title: String
    let icon: String
    var fontColour: Color = .primaryText
    var circleColor: Color = .blue
    var cornerRadius: CGFloat = 12
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(circleColor.opacity(0.2))
                    )
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(fontColour)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.backgroundColour.opacity(0.6))
            )
        }
    }
}
