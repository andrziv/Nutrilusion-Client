//
//  MealGroups.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-01.
//

import Foundation

struct MealGroup: Identifiable {
    let id: UUID
    var name: String
    var meals: [FoodItem]
    var colour: String
}

extension MockData {
    static let sampleMealGroup: MealGroup = .init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Breakfast",
        meals: [
            sampleFoodItem,
            foodItemList[4],
            foodItemList[5]
        ],
        colour: "#0095ff"
    )
    
    static var mealGroupList: [MealGroup] = [
        sampleMealGroup,
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Lunch",
            meals: [
                foodItemList[1],
                foodItemList[3],
                foodItemList[8]
            ],
            colour: "#ffeb3b"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Dinner",
            meals: [
                foodItemList[6],
                foodItemList[9]
            ],
            colour: "#ff5252"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Off-the-Shelf",
            meals: [
                foodItemList[1],
                foodItemList[2],
                foodItemList[7]
            ],
            colour: "#a319ff"),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            name: "Generated Foods",
            meals: Array(foodItemList.dropFirst(10)), // num of manually-created meals
            colour: "#4caf50"
        )
    ]
}
