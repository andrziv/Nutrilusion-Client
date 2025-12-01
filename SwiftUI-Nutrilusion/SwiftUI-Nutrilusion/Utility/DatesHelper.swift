//
//  DatesHelper.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import Foundation

func dateMonthDayYearFormat() -> Date.FormatStyle {
    Date.FormatStyle()
        .year(.defaultDigits)
        .month(.abbreviated)
        .day(.twoDigits)
}
