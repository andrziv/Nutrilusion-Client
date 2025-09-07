//
//  NutrientImageMapping.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import Foundation

struct NutrientImageMapping {
    var nutrientType: String
    var nutrientImage: String
}

extension NutrientImageMapping {
    static let allCases = [
        "Carbohydrates": "c.circle.fill",
        "Protein": "p.circle.fill",
        "Proteins": "p.circle.fill",
        "Fat": "f.circle.fill",
        "Fats": "f.circle.fill",
        "Fiber": "tree.fill",
        "Fibers": "tree.fill",
        "Calories": "flame.fill"]
}
