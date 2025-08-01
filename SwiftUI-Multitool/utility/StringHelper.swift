//
//  StringHelper.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import Foundation

func RoundingDouble(_ number: Double, precision: Int = 1) -> String {
    let isInteger = number.truncatingRemainder(dividingBy: 1) == 0
    return isInteger ? String(Int(number)) : String(format: "%.\(precision)f", number)
}
