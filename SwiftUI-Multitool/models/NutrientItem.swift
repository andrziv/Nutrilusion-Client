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
        
        for nutrient in childNutrients {
            if let found = nutrient.getChildNutrientValue(nutrientType) {
                return found
            }
        }
        
        return nil
    }
    
    func flattenChildren() -> [NutrientItem] {
        var result: [NutrientItem] = []
        for child in childNutrients {
            result.append(child)
            result.append(contentsOf: child.flattenChildren())
        }
        return result
    }
}
