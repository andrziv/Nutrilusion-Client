//
//  GranularValueTextField.swift
//  SwiftUI-Nutrilusion
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
        HStack(alignment: .center, spacing: 4) {
            ImagedButton(title: RoundingDouble(topChangeValue), icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value = max(0, value - topChangeValue)
            }
            ImagedButton(title: RoundingDouble(topChangeValue - interval), icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value = max(0, value - topChangeValue + interval)
            }
            
            let isUnitTextLong = unitText != nil && unitText!.count > 3
            SwappingVHStack(vSpacing: 0, hSpacing: 4, hAlignment: .center, vAlignment: .center, useHStack: !isUnitTextLong) {
                BasicTextField("", value: $value, format: .number,
                               font: .subheadline,
                               fontWeight: .regular,
                               cornerRadius: 7,
                               outline: .clear, outlineWidth: 0,
                               background: background,
                               horizontalPadding: 6,
                               verticalPadding: isUnitTextLong ? -1 : 5)
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .onChange(of: value) { _, newValue in
                    value = max(0, newValue)
                }
                
                if let unitText, !unitText.isEmpty {
                    Text(unitText)
                        .scaledToFit()
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .font(.caption2)
                        .fontWeight(.light)
                        .padding(.trailing, isUnitTextLong ? 0 : 4)
                }
            }
            .background(RoundedRectangle(cornerRadius: 7).fill(background))
            .onTapGesture {
                isFocused = true
            }
            
            ImagedButton(title: RoundingDouble(topChangeValue - interval), icon: "plus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: background,
                         iconPlacement: .leading) {
                value += topChangeValue - interval
            }
            ImagedButton(title: RoundingDouble(topChangeValue), icon: "plus",
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
