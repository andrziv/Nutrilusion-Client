//
//  LoggedMealItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import Foundation

struct LoggedMealItem {
    var date: Date = Date()
    var meal: FoodItem
    var servingMultiple: Double = 1.0
}

extension MockData {
    static let loggedMeals: [LoggedMealItem] = [
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            meal: sampleFoodItem,
            servingMultiple: 1.0
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            meal: foodItemList[3], // Lasagna
            servingMultiple: 1.5
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            meal: foodItemList[1], // Greek Yogurt
            servingMultiple: 2.0
        ),
        LoggedMealItem(
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            meal: foodItemList[4], // Chicken Salad
            servingMultiple: 1.0
        ),
        LoggedMealItem(
            date: Date(),
            meal: foodItemList[8], // Spaghetti Bolognese
            servingMultiple: 0.75
        )
    ]
}
