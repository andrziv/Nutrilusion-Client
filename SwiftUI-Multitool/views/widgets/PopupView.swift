//
//  PopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//

import SwiftUI

struct PopupView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PopupTextField: View {
    @Binding var textBinding: String
    var placeholder: String
    var outline: Color = .gray
    var background: Color = .white
    
    var body: some View {
        TextField(placeholder, text: $textBinding)
            .font(.headline)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .stroke(outline, lineWidth: 0.5)
                .fill(background))
    }
}

#Preview {
    PopupView()
}
