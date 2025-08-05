//
//  NutrientItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

struct NutrientItem: Identifiable {
    var id: UUID = UUID()
    var name: String
    var amount: Double
    var unit: String
    var childNutrients: [NutrientItem] = []
    
    func getChildNutrientValue(_ nutrientType: String) -> NutrientItem? {
        for nutrient in childNutrients {
            if nutrient.name == nutrientType {
                return nutrient
            }
        }
        return nil
    }
}
