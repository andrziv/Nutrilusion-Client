//
//  LoggedMealItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI

struct LoggedMealItem {
    let id: UUID = UUID()
    var date: Date = Date()
    var meal: FoodItem
    var servingMultiple: Double = 1.0
    var importantNutrients: [NutrientItem] = []
    var imageName: String?
    var emblemColour: Color // TODO: needs to be tied into the food item groups later on
}

extension MockData {
    static let loggedMeals: [LoggedMealItem] = [
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            meal: sampleFoodItem,
            servingMultiple: 1.0,
            importantNutrients: sampleFoodItem.nutritionList,
            emblemColour: .purple
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            meal: foodItemList[3], // Lasagna
            servingMultiple: 1.5,
            importantNutrients: foodItemList[3].nutritionList,
            emblemColour: .blue
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            meal: foodItemList[1], // Greek Yogurt
            servingMultiple: 2.0,
            importantNutrients: foodItemList[1].nutritionList,
            emblemColour: .green
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            meal: foodItemList[4], // Chicken Salad
            servingMultiple: 1.0,
            importantNutrients: foodItemList[4].nutritionList,
            emblemColour: .orange
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            meal: foodItemList[2], // Apple
            servingMultiple: 1.0,
            importantNutrients: foodItemList[4].nutritionList,
            emblemColour: .orange
        ),
        LoggedMealItem(
            date: Date(),
            meal: foodItemList[8], // Spaghetti Bolognese
            servingMultiple: 0.75,
            importantNutrients: foodItemList[8].nutritionList,
            emblemColour: .pink
        )
    ]
}
