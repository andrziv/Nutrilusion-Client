//
//  StringHelper.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import Foundation

func RoundingDouble(_ number: Double, precision: Int = 1) -> String {
    let roundedNumber = round(number, exp: precision)
    let isInteger = roundedNumber.truncatingRemainder(dividingBy: 1) == 0
    return isInteger ? String(Int(roundedNumber)) : String(format: "%.\(precision)f", roundedNumber)
}
