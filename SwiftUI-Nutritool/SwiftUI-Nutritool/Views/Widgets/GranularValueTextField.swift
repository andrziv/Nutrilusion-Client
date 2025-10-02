//
//  GranularValueTextField.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-10-02.
//


import SwiftUI

struct GranularValueTextField: View {
    var topChangeValue: Double = 1
    var interval: Double = 0.5
    @Binding var value: Double
    var background: Color = .gray
    var unitText: String?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ImagedButton(title: "1", icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value = Swift.max(0, value - topChangeValue)
            }
            ImagedButton(title: "0.5", icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value = Swift.max(0, value - topChangeValue + interval)
            }
            
            HStack {
                BasicTextField("", value: $value, format: .number,
                               font: .subheadline,
                               fontWeight: .regular,
                               cornerRadius: 7,
                               outline: .clear, outlineWidth: 0,
                               background: background,
                               horizontalPadding: 6,
                               verticalPadding: 6)
                .focused($isFocused)
                .multilineTextAlignment(.center)
                
                if let unitText {
                    Text(unitText)
                        .font(.caption2)
                        .fontWeight(.light)
                        .padding(.trailing, 4)
                }
            }
            .background(RoundedRectangle(cornerRadius: 7).fill(background))
            .onTapGesture {
                isFocused = true
            }
            
            ImagedButton(title: "0.5", icon: "plus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value += topChangeValue - interval
            }
            ImagedButton(title: "1", icon: "plus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value += topChangeValue
            }
        }
    }
}
