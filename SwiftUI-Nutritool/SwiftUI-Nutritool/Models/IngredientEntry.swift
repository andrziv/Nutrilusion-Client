//
//  IngredientEntry.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-10-01.
//

import Foundation

struct IngredientEntry: Identifiable, Equatable {
    var id: String
    var ingredientID: UUID
    var version: Int = 0
    var ingredient: FoodItem
    var servingMultiplier: Double = 1.0
    
    init(compositeID: String? = nil, id: UUID = UUID(), version: Int = 0,
         ingredient: FoodItem, servingMultiplier: Double = 0) {
        if let compositeID = compositeID {
            self.id = compositeID
        } else {
            self.id = compositeId(id, version: version)
        }
        
        self.ingredientID = id
        self.version = version
        self.ingredient = ingredient
        self.version = version
    }
}
