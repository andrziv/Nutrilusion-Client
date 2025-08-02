//
//  MealGroups.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-01.
//

import Foundation

struct MealGroup {
    var name: String
    var meals: [FoodItem]
    var colour: String
}

extension MockData {
    static let sampleMealGroup: MealGroup = .init(
        name: "Breakfast",
        meals: [
            sampleFoodItem,
            foodItemList[4],
            foodItemList[5]
        ],
        colour: "#0095ff"
    )
    
    static let mealGroupList: [MealGroup] = [
        sampleMealGroup,
        .init(
            name: "Lunch",
            meals: [
                foodItemList[1],
                foodItemList[8],
                foodItemList[9]
            ],
            colour: "#ffeb3b"
        ),
        .init(
            name: "Dinner",
            meals: [
                foodItemList[6],
                foodItemList[9]
            ],
            colour: "#ff5252"
        ),
        .init(name: "Off-the-Shelf",
              meals: [
                foodItemList[1],
                foodItemList[2],
                foodItemList[7]
              ],
              colour: "#a319ff")
    ]
}
