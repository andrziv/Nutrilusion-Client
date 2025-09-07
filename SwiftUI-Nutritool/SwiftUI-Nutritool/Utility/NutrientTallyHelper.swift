//
//  NutrientTallyHelper.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import Foundation

func sumCalories(_ foods: [LoggedMealItem]) -> Double {
    var totalNutrient = 0.0
    for food in foods {
        totalNutrient += getCalories(food)
    }
    return totalNutrient
}

func getCalories(_ food: LoggedMealItem) -> Double {
    return food.servingMultiple * Double(food.meal.calories)
}

func sumNutrients(_ nutrientType: String, _ foods: [LoggedMealItem]) -> Double {
    var totalNutrient = 0.0
    for food in foods {
        totalNutrient += getNutrientValue(nutrientType, food)
    }
    return totalNutrient
}

func getNutrientValue(_ nutrientType: String, _ food: LoggedMealItem) -> Double {
    if let nutrient = food.meal.getNutrient(nutrientType) {
        return food.servingMultiple * nutrient.amount
    }
    return 0
}


