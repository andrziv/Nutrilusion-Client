//
//  NoiseShader.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-08.
//

import SwiftUI

extension View {
    func randomNoiseShader(isAnimate: Bool = true) -> some View {
        modifier(NoiseShader(isAnimate: isAnimate))
    }
}
 
struct NoiseShader: ViewModifier {
    var isAnimate: Bool = true
    let startDate = Date()
 
    func body(content: Content) -> some View {
        if isAnimate {
            TimelineView(.animation) { _ in
                content
                    .colorEffect(
                        ShaderLibrary.randomNoise(
                            .float(startDate.timeIntervalSinceNow)
                        )
                    )
            }
        } else {
            content
                .colorEffect(
                    ShaderLibrary.randomNoise(
                        .float(startDate.timeIntervalSinceNow)
                    )
                )
        }
    }
}
