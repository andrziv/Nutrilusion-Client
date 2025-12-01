//
//  ScrollCommand.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-10-07.
//


import SwiftUI

struct ScrollCommand: Equatable {
    let hour: Int
    let id = UUID()
    
    static func recentHourCommand() -> ScrollCommand {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        return ScrollCommand(hour: max(currentHour, 0))
    }
    
    static func scrollToHour(_ scrollProxy: ScrollViewProxy, hour: Int) {
        withAnimation {
            let topPoint: UnitPoint = .top
            scrollProxy.scrollTo("hour-\(hour)", anchor: .init(x: topPoint.x, y: topPoint.y + 0.1))
        }
    }
    
    static func scrollToHourNoAnimation(_ scrollProxy: ScrollViewProxy, hour: Int) {
        let topPoint: UnitPoint = .top
        scrollProxy.scrollTo("hour-\(hour)", anchor: .init(x: topPoint.x, y: topPoint.y + 0.1))
    }
}
