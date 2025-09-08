//
//  ImagedButton.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

enum IconPlacement {
    case leading, trailing, top, bottom
    
    @ViewBuilder
    func arrange<Icon: View, Label: View>(
        icon: Icon,
        label: Label
    ) -> some View {
        switch self {
        case .leading:
            HStack(spacing: 10) {
                icon
                label
            }
        case .trailing:
            HStack(spacing: 10) {
                label
                icon
            }
        case .top:
            VStack(spacing: 6) {
                icon
                label
            }
        case .bottom:
            VStack(spacing: 6) {
                label
                icon
            }
        }
    }
}

struct ImagedButton<T>: View {
    let title: String
    let icon: String
    var fontColour: Color = .primaryText
    var circleColour: Color = .blue
    var cornerRadius: CGFloat = 12
    var maxWidth: CGFloat?
    var iconPlacement: IconPlacement = .leading
    
    let action: (T) -> Void
    var item: T
    
    var body: some View {
        Button {
            action(item)
        } label: {
            iconPlacement.arrange(icon: iconView, label: textView)
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
    
    private var iconView: some View {
        Image(systemName: icon)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(circleColour.opacity(0.2))
            )
    }
    
    private var textView: some View {
        Text(title)
            .font(.headline)
    }
}

extension ImagedButton where T == Void {
    init(title: String,
         icon: String,
         fontColour: Color = .primaryText,
         circleColour: Color = .blue,
         cornerRadius: CGFloat = 12,
         maxWidth: CGFloat? = nil,
         iconPlacement: IconPlacement = .leading,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.fontColour = fontColour
        self.circleColour = circleColour
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.iconPlacement = iconPlacement
        self.action = { _ in action() }
    }
}
