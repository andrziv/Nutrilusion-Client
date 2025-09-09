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

struct ImagedButton<Item>: View {
    let title: String?
    let icon: String
    
    var fontColour: Color = .primaryText
    var imageFont: Font = .callout
    var textFont: Font = .headline
    
    var circleColour: Color = .blue
    var cornerRadius: CGFloat = 12
    var verticalPadding: CGFloat = 11.5
    var horizontalPadding: CGFloat = 12
    var maxWidth: CGFloat? = nil
    var backgroundColour: Color = .secondaryBackground
    
    var iconPlacement: IconPlacement = .leading
    
    let item: Item
    let action: (Item) -> Void
    
    var body: some View {
        Button {
            action(item)
        } label: {
            iconPlacement
                .arrange(icon: iconView, label: textView)
                .foregroundStyle(fontColour)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: maxWidth)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(backgroundColour)
                )
        }
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(imageFont)
            .background(Circle().fill(circleColour.opacity(0.2)))
    }
    
    private var textView: some View {
        if let title {
            AnyView(Text(title).font(textFont))
        } else {
            AnyView(EmptyView())
        }
    }
}

extension ImagedButton where Item == Void {
    init(title: String?,
         icon: String,
         fontColour: Color = .primaryText,
         imageFont: Font = .callout,
         textFont: Font = .headline,
         circleColour: Color = .blue,
         cornerRadius: CGFloat = 12,
         verticalPadding: CGFloat = 11.5,
         horizontalPadding: CGFloat = 12,
         maxWidth: CGFloat? = nil,
         backgroundColour: Color = .secondaryBackground,
         iconPlacement: IconPlacement = .leading,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        
        self.fontColour = fontColour
        self.imageFont = imageFont
        self.textFont = textFont
        
        self.circleColour = circleColour
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.maxWidth = maxWidth
        self.backgroundColour = backgroundColour
        
        self.iconPlacement = iconPlacement
        
        self.action = { _ in action() }
        self.item = ()
    }
}
