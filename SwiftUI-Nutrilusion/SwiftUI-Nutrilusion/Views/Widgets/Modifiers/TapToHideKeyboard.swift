//
//  Untitled.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-10-06.
//

import SwiftUI

struct TapToHideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
    }
}

// For future me: As of iOS 18 (or 26) when I am writing this, SwiftUI has no clean way to remove the keyboard when you tap outside of it, unlike a picker.
//  This nastiness is just to get around that.
extension View {
    func tapToHideKeyboard() -> some View {
        self.modifier(TapToHideKeyboardModifier())
    }
}
