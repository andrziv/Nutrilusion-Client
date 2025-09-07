//
//  AnimatedBackgroundGradient.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-03.
//

import SwiftUI

struct AnimatedBackgroundGradient: View {
    var colours: [Color]
    var radius: CGFloat = 15
    var cornerRadius: CGFloat = 15
    var clipToShape: Bool = true
    @Binding var isActive: Bool
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1, paused: isActive)) { context in
            let time = context.date.timeIntervalSince1970
            let offsetX = Float(sin(time)) * 0.1
            let offsetY = Float(cos(time)) * 0.1
            
            let gradient = MeshGradient(
                width: 4,
                height: 4,
                points: [
                    [0.0, 0.0],
                    [0.3, 0.0],
                    [0.7, 0.0],
                    [1.0, 0.0],
                    [0.0, 0.3],
                    [0.2 + offsetX, 0.4 + offsetY],
                    [0.7 + offsetX, 0.2 + offsetY],
                    [1.0, 0.3],
                    [0.0, 0.7],
                    [0.3 + offsetX, 0.8],
                    [0.7 + offsetX, 0.6],
                    [1.0, 0.7],
                    [0.0, 1.0],
                    [0.3, 1.0],
                    [0.7, 1.0],
                    [1.0, 1.0]
                ],
                colors: colours
            ).blur(radius: radius)
            
            if clipToShape {
                gradient.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                gradient
            }
        }
    }
}

