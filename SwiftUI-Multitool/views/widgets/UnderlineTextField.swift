//
//  UnderlineTextField.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct UnderlineTextField: View {
    @Binding var textBinding: String
    var placeholder: String
    var cornerRadius: CGFloat = 10
    var borderColour: Color = .backgroundColour
    var backgroundColour: Color = .clear
    
    var body: some View {
        TextField(placeholder, text: $textBinding)
            .padding(10)
            .background(Rectangle().fill(.clear).background(backgroundColour))
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)))
            .edgeBorder(colour: borderColour, thickness: 2)
    }
}

struct UnderlineIntField: View {
    @Binding var numberBinding: Int
    var placeholder: String
    var cornerRadius: CGFloat = 10
    var borderColour: Color = .backgroundColour
    var backgroundColour: Color = .clear
    
    var body: some View {
        TextField(placeholder, value: $numberBinding, format: .number)
            .padding(10)
            .background(Rectangle().fill(backgroundColour))
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)))
            .edgeBorder(colour: borderColour, thickness: 2)
    }
}

struct UnderlineDoubleField: View {
    @Binding var numberBinding: Double
    var placeholder: String
    var cornerRadius: CGFloat = 10
    var borderColour: Color = .backgroundColour
    var backgroundColour: Color = .clear
    
    var body: some View {
        TextField(placeholder, value: $numberBinding, format: .number)
            .padding(10)
            .background(Rectangle().fill(backgroundColour))
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)))
            .edgeBorder(colour: borderColour, thickness: 2)
    }
}
