//
//  NumberHelper.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-30.
//

import Foundation

func round(_ value: Double, exp exponent: Int) -> Double {
    let rounder = pow(10.0, Double(exponent))
    return (value * rounder).rounded() / rounder
}
