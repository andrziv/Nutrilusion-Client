//
//  CheckBoxStyle.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-10-05.
//


import SwiftUI

struct CheckBoxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                
                configuration.label
            }
        })
    }
}