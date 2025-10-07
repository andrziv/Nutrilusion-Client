//
//  ScrollCommand.swift
//  SwiftUI-Nutritool
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
        
        return ScrollCommand(hour: max(currentHour - 1, 0))
    }
    
    static func scrollToHour(_ scrollProxy: ScrollViewProxy, hour: Int) {
        withAnimation {
            scrollProxy.scrollTo("hour-\(hour)", anchor: .top)
        }
    }
    
    static func scrollToHourNoAnimation(_ scrollProxy: ScrollViewProxy, hour: Int) {
        scrollProxy.scrollTo("hour-\(hour)", anchor: .top)
    }
}
