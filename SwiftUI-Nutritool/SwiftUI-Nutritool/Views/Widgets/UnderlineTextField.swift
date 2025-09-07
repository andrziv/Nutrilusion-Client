//
//  UnderlineTextField.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct UnderlineTextField<Value>: View {
    private var cornerRadius: CGFloat = 10
    private var borderWidth: CGFloat = 2
    private var borderColour: Color = .backgroundColour
    private var backgroundColour: Color = .clear
    
    private let _body: AnyView
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        cornerRadius: CGFloat = 10,
        borderWidth: CGFloat = 2,
        borderColour: Color = .gray,
        backgroundColour: Color = .backgroundColour
    ) where Value == String {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColour = borderColour
        self.backgroundColour = backgroundColour
        
        self._body = AnyView(
            TextField(placeholder, text: text)
        )
    }
    
    init<F>(
        _ placeholder: String,
        value: Binding<Value>,
        format: F,
        cornerRadius: CGFloat = 10,
        borderWidth: CGFloat = 2,
        borderColour: Color = .gray,
        backgroundColour: Color = .backgroundColour
    ) where F: ParseableFormatStyle, F.FormatInput == Value, F.FormatOutput == String {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColour = borderColour
        self.backgroundColour = backgroundColour
        
        self._body = AnyView(
            TextField(placeholder, value: value, format: format)
        )
    }
    
    var body: some View {
        _body
            .edgeBorder(colour: borderColour, thickness: borderWidth)
            .background(Rectangle().fill(.clear).background(backgroundColour))
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)))
    }
}
