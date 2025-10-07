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
    
    static func recentHour() -> Int {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        return max(currentHour - 1, 0)
    }
    
    static func scrollToRecentHour(_ scrollProxy: ScrollViewProxy) {
        // target one hour before current for user to see a recent time
        let targetHour = recentHour()

        withAnimation {
            scrollProxy.scrollTo("hour-\(targetHour)", anchor: .top)
        }
    }
    
    static func scrollToHour(_ scrollProxy: ScrollViewProxy, hour: Int) {
        withAnimation {
            scrollProxy.scrollTo("hour-\(hour)", anchor: .top)
        }
    }
}
