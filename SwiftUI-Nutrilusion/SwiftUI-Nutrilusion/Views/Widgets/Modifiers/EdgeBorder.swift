//
//  EdgeBorder.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-24.
//

import SwiftUI

enum BorderAlignment {
    case top
    case bottom
    case leading
    case trailing
    
    fileprivate var width: CGFloat? {
        switch self {
        case .top:
            return nil
        case .bottom:
            return nil
        case .leading:
            return 1
        case .trailing:
            return 1
        }
    }
    
    fileprivate var height: CGFloat? {
        switch self {
        case .top:
            return 1
        case .bottom:
            return 1
        case .leading:
            return nil
        case .trailing:
            return nil
        }
    }
    
    fileprivate var paddingAlignment: Edge.Set {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
    
    fileprivate var borderAlignment: Alignment {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

struct EdgeBorder: ViewModifier {
    var alignment: BorderAlignment = .bottom
    var colour: Color = .secondaryText
    var thickness: CGFloat = 1
    
    func body(content: Content) -> some View {
        let width: CGFloat? = alignment.width == nil ? nil : alignment.width! * thickness
        let height: CGFloat? = alignment.height == nil ? nil : alignment.height! * thickness
        
        content
            .padding(alignment.paddingAlignment, thickness)
            .background(
                Rectangle()
                    .frame(width: width, height: height, alignment: alignment.borderAlignment)
                    .foregroundStyle(colour), alignment: alignment.borderAlignment)
    }
}

extension View {
    func edgeBorder(alignment: BorderAlignment = .bottom, colour: Color = .gray, thickness: CGFloat = 1) -> some View {
        self.modifier(
            EdgeBorder(
                alignment: alignment,
                colour: colour,
                thickness: thickness
            )
        )
    }
}

#Preview {
    VStack {
        Text("Test1")
            .edgeBorder(alignment: .bottom, colour: .red, thickness: 4)
        
        Text("Test2")
            .edgeBorder(alignment: .trailing, colour: .blue, thickness: 10)
        
        Text("Test3")
            .edgeBorder(alignment: .leading, colour: .green, thickness: 2)
        
        Text("Test4")
            .edgeBorder(alignment: .top, colour: .yellow, thickness: 20)
    }
}
