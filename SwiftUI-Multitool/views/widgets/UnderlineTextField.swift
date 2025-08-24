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
    
    var body: some View {
        TextField(placeholder, text: $textBinding)
            .padding(10)
            .background(Rectangle().fill(.clear).background(.thinMaterial))
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)))
            .edgeBorder(colour: borderColour, thickness: 2)
    }
}