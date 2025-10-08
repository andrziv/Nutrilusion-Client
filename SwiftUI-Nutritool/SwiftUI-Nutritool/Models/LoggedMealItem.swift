//
//  LoggedMealItem.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI
import UniformTypeIdentifiers

struct LoggedMealItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var meal: FoodItem
    var servingMultiple: Double = 1.0
    var importantNutrients: [NutrientItem] = []
    var emblemColour: String
    
    func getColour() -> Color {
        return Color(hex: emblemColour)
    }
}

extension UTType {
    static let loggedMealItem = UTType(exportedAs: "akiswifts.SwiftUI-Nutritool.loggedMealItem")
}

extension MockData {
    static let loggedMeals: [LoggedMealItem] = [
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            meal: sampleFoodItem,
            servingMultiple: 1.0,
            importantNutrients: sampleFoodItem.nutritionList,
            emblemColour: Color.purple.toHex()
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .minute, value: -90, to: Date()) ?? Date(),
            meal: foodItemList[3], // Lasagna
            servingMultiple: 1.5,
            importantNutrients: foodItemList[3].nutritionList,
            emblemColour: Color.blue.toHex()
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            meal: foodItemList[1], // Greek Yogurt
            servingMultiple: 2.0,
            importantNutrients: foodItemList[1].nutritionList,
            emblemColour: Color.green.toHex()
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            meal: foodItemList[4], // Chicken Salad
            servingMultiple: 1.0,
            importantNutrients: foodItemList[4].nutritionList,
            emblemColour: Color.orange.toHex()
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            meal: foodItemList[2], // Apple
            servingMultiple: 1.0,
            importantNutrients: foodItemList[4].nutritionList,
            emblemColour: Color.orange.toHex()
        ),
        LoggedMealItem(
            date: Date(),
            meal: foodItemList[8], // Spaghetti Bolognese
            servingMultiple: 0.75,
            importantNutrients: foodItemList[8].nutritionList,
            emblemColour: Color.pink.toHex()
        )
    ]
}
