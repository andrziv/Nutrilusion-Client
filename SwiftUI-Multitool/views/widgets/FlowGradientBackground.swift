//
//  FlowGradientBackground.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-15.
//


import SwiftUI

struct FlowGradientBackground: View {
    var colour: Color = .blue
    var toMixWith: Color = .white
    
    var body: some View {
        let lightColour = colour.mix(with: toMixWith, by: 0.3)
        let lighterColour = colour.mix(with: toMixWith, by: 0.45)
        let lightestColour = colour.mix(with: toMixWith, by: 0.6)
        
        MeshGradient(
            width: 4,
            height: 4,
            points: [
                [0.0, 0.0],
                [0.3, 0.0],
                [0.7, 0.0],
                [1.0, 0.0],
                [0.0, 0.3],
                [0.2, 0.4],
                [0.7, 0.2],
                [1.0, 0.3],
                [0.0, 0.7],
                [0.3, 0.8],
                [0.7, 0.6],
                [1.0, 0.7],
                [0.0, 1.0],
                [0.3, 1.0],
                [0.7, 1.0],
                [1.0, 1.0]
            ],
            colors: [
                lightestColour, lightestColour, colour, colour,
                colour, colour, lightColour, lighterColour,
                lightColour, lightColour, lighterColour, lightestColour,
                lightColour, lighterColour, lightestColour, colour
            ]
        )
    }
}

#Preview {
    FlowGradientBackground(colour: .blue, toMixWith: .white)
        .ignoresSafeArea()
}
