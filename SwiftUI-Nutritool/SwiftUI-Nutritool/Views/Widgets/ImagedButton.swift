//
//  ImagedButton.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct ImagedButton<T>: View {
    let title: String
    let icon: String
    var fontColour: Color = .primaryText
    var circleColour: Color = .blue
    var cornerRadius: CGFloat = 12
    var maxWidth: CGFloat?
    
    let action: (T) -> Void
    var item: T
    
    var body: some View {
        Button {
            action(item)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(circleColour.opacity(0.2))
                    )
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(fontColour)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: maxWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.secondaryBackground)
            )
        }
    }
}

extension ImagedButton where T == Void {
    init(title: String,
         icon: String,
         fontColour: Color = .primaryText,
         circleColour: Color = .blue,
         cornerRadius: CGFloat = 12,
         maxWidth: CGFloat? = nil,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.fontColour = fontColour
        self.circleColour = circleColour
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.action = { _ in action() }
    }
}
