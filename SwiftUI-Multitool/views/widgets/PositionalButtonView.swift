//
//  PositionalButtonView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-27.
//

import SwiftUI

struct Position {
    let shape: AnyShape
    
    private init(_ shape: AnyShape) {
        self.shape = shape
    }
}

extension Position {
    static let left = Position(AnyShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 20))))
    static let mid = Position(AnyShape(Rectangle()))
    static let right = Position(AnyShape(UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 20, topTrailing: 20))))
}

struct PositionalButtonView: View {
    var toptext: String = ""
    var maintext: String
    var position: Position
    var isSelected: Bool = false
    var background: Color = .white
    var foreground: Color = .gray
    
    var body: some View {
        VStack {
            Text(toptext)
                .font(.system(size: isSelected ? 12 : 10, weight: isSelected ? .medium : .light, design: .default))
            Text(maintext)
                .font(.system(size: isSelected ? 16 : 14, weight: isSelected ? .medium : .light, design: .default))
        }
        .foregroundStyle(isSelected ? .black : .secondary)
        .padding([.top, .bottom], 10)
        .frame(maxWidth: .infinity)
        .background(background)
        .foregroundColor(foreground)
        .clipShape(
            position.shape
        )
    }
}

#Preview {
    PositionalButtonView(maintext: "mon", position: .left, background: .black, foreground: .white)
}
