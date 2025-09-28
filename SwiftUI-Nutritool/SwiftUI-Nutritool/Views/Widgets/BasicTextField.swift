//
//  BasicTextField.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//

import SwiftUI

struct BasicTextField<Value>: View {
    private var cornerRadius: CGFloat
    private var outline: Color
    private var outlineWidth: CGFloat
    private var background: Color
    private var horizontalPadding: CGFloat
    private var verticalPadding: CGFloat
    
    @FocusState private var isFocused: Bool
    private let _body: AnyView
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        cornerRadius: CGFloat = 10,
        outline: Color = .gray,
        outlineWidth: CGFloat = 0.5,
        background: Color = .backgroundColour,
        horizontalPadding: CGFloat = 15.5,
        verticalPadding: CGFloat = 15.5
    ) where Value == String {
        self.cornerRadius = cornerRadius
        self.outline = outline
        self.outlineWidth = outlineWidth
        self.background = background
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        
        self._body = AnyView(
            TextField(placeholder, text: text)
        )
    }
    
    init<F>(
        _ placeholder: String,
        value: Binding<Value>,
        format: F,
        cornerRadius: CGFloat = 10,
        outline: Color = .gray,
        outlineWidth: CGFloat = 0.5,
        background: Color = .backgroundColour,
        horizontalPadding: CGFloat = 15.5,
        verticalPadding: CGFloat = 15.5
    ) where F: ParseableFormatStyle, F.FormatInput == Value, F.FormatOutput == String {
        self.cornerRadius = cornerRadius
        self.outline = outline
        self.outlineWidth = outlineWidth
        self.background = background
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        
        self._body = AnyView(
            TextField(placeholder, value: value, format: format)
        )
    }
    
    var body: some View {
        _body
            .focused($isFocused)
            .font(.headline)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outline, lineWidth: outlineWidth)
                    .fill(background)
            )
            .onTapGesture {
                isFocused = true
            }
    }
}


#Preview {
    BasicTextField("Placeholder Text...", text: .constant("Hello"))
}
