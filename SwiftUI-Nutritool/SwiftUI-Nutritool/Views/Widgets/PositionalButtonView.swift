//
//  PositionalButtonView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-27.
//

import SwiftUI

fileprivate enum PositionKind {
    case topmid, botmid, left, mid, right
}

struct Position {
    fileprivate let kind: PositionKind
    let cornerRadius: CGFloat
    
    var shape: AnyShape {
        switch kind {
        case .topmid:
            return AnyShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)
                )
            )
        case .botmid:
            return AnyShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(bottomLeading: cornerRadius, bottomTrailing: cornerRadius)
                )
            )
        case .left:
            return AnyShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: cornerRadius, bottomLeading: cornerRadius)
                )
            )
        case .right:
            return AnyShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(bottomTrailing: cornerRadius, topTrailing: cornerRadius)
                )
            )
        case .mid:
            return AnyShape(Rectangle())
        }
    }
}

extension Position {
    static let topmid = Position(kind: .topmid, cornerRadius: 20)
    static let botmid = Position(kind: .botmid, cornerRadius: 20)
    static let left   = Position(kind: .left,   cornerRadius: 20)
    static let right  = Position(kind: .right,  cornerRadius: 20)
    static let mid    = Position(kind: .mid,    cornerRadius: 0)
}

struct PositionalButtonView<S: ShapeStyle>: View {
    var topText: String = ""
    var mainText: String
    var position: Position
    var isSelected: Bool = false

    // Configurable styles
    var cornerRadius: CGFloat = 20
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
        let customPosition = Position(kind: position.kind, cornerRadius: cornerRadius)
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
        .clipShape(customPosition.shape)
        .shadow(color: isSelected ? .primaryText.opacity(0.15) : .clear, radius: isSelected ? 4 : 0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    VStack(spacing: 30) {
        VStack(spacing: 2) {
            PositionalButtonView(mainText: "topmid", position: .topmid, background: .regularMaterial, foreground: .primaryText)
            PositionalButtonView(mainText: "mid", position: .mid, background: .regularMaterial, foreground: .primaryText)
            PositionalButtonView(mainText: "botmid", position: .botmid, isSelected: true, background: .regularMaterial, foreground: .primaryText)
        }
        
        HStack(spacing: 2) {
            PositionalButtonView(mainText: "left", position: .left, background: .regularMaterial, foreground: .primaryText)
            PositionalButtonView(mainText: "mid", position: .mid, isSelected: true, background: .regularMaterial, foreground: .primaryText)
            PositionalButtonView(mainText: "right", position: .right, background: .regularMaterial, foreground: .primaryText)
        }
    }
    .padding()
}
