//
//  PositionalButtonView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-27.
//

import SwiftUI

struct Position {
    let shape: AnyShape
    
    private init(_ shape: AnyShape) {
        self.shape = shape
    }
}

extension Position {
    static let left = Position(AnyShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 20))))
    static let mid = Position(AnyShape(Rectangle()))
    static let right = Position(AnyShape(UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 20, topTrailing: 20))))
}

struct PositionalButtonView<S: ShapeStyle>: View {
    var topText: String = ""
    var mainText: String
    var position: Position
    var isSelected: Bool = false

    // Configurable styles
    var background: S
    var foreground: Color = .primaryText
    var selectedForeground: Color = .primaryText
    var borderColor: Color = .blue
    var borderWidth: CGFloat = 2
    var selectedBackground: AnyShapeStyle = AnyShapeStyle(Color.blue.opacity(0.2))

    // Font settings
    var topFontSize: CGFloat = 10
    var topFontSizeSelected: CGFloat = 12
    var mainFontSize: CGFloat = 14
    var mainFontSizeSelected: CGFloat = 16
    var topFontWeight: Font.Weight = .light
    var topFontWeightSelected: Font.Weight = .medium
    var mainFontWeight: Font.Weight = .light
    var mainFontWeightSelected: Font.Weight = .medium

    // Padding
    var verticalPadding: CGFloat = 10
    var verticalPaddingSelected: CGFloat = 8

    var body: some View {
        VStack {
            if !topText.isEmpty {
                Text(topText)
                    .font(.system(
                        size: isSelected ? topFontSizeSelected : topFontSize,
                        weight: isSelected ? topFontWeightSelected : topFontWeight
                    ))
            }
            Text(mainText)
                .font(.system(
                    size: isSelected ? mainFontSizeSelected : mainFontSize,
                    weight: isSelected ? mainFontWeightSelected : mainFontWeight
                ))
        }
        .foregroundStyle(isSelected ? selectedForeground : foreground)
        .padding(.vertical, isSelected ? verticalPaddingSelected : verticalPadding)
        .frame(maxWidth: .infinity)
        .background(isSelected ? selectedBackground : AnyShapeStyle(background))
        .clipShape(position.shape)
        .shadow(color: isSelected ? .primaryText.opacity(0.15) : .clear, radius: isSelected ? 4 : 0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


#Preview {
    PositionalButtonView(mainText: "mon", position: .left, background: .backgroundColour, foreground: .primaryText)
}
