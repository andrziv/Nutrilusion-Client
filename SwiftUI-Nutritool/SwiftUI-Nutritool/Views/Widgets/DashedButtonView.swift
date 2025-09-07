//
//  DashedButtonView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-02.
//


import SwiftUI

struct DashedButtonView: View {
    let imageName: String
    var cornerRadius: CGFloat = 15
    var lineWidth: CGFloat = 1
    var strokePattern: [CGFloat] = [8]
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundStyle(.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.clear)
            .overlay{
                RoundedRectangle(cornerRadius: 15)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundStyle(.primaryText.mix(with: .backgroundColour, by: 0.5))
            }
    }
}
