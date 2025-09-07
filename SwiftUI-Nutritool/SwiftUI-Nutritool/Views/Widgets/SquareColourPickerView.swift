//
//  SquareColourPickerView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-10.
//


import SwiftUI

struct SquareColourPickerView: View {
    var text: String = ""
    @Binding var selection: Color
    
    private let shape: some Shape = RoundedRectangle(cornerRadius: 10.0)
    
    var body: some View {
        HStack {
            if !text.isEmpty {
                Text(text)
            }
            
            ZStack(alignment: .center) {
                ColorPicker("", selection: $selection).labelsHidden().scaleEffect(CGSize(width: 1.9, height: 1.9))
                    .clipShape(shape)
                
                selection
                    .frame(width: 35, height: 35, alignment: .center)
                    .cornerRadius(10.0)
                    .overlay(shape.stroke(.background, style: StrokeStyle(lineWidth: 5)))
                    .padding(10)
                    .background(AngularGradient(gradient: Gradient(colors: [.red,.yellow,.green,.blue,.purple,.pink]), center:.center).cornerRadius(20.0))
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    SquareColourPickerView(selection: .constant(.blue))
    SquareColourPickerView(text: "Test", selection: .constant(.blue))
}
