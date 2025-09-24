//
//  MealGroups.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-01.
//

import Foundation

struct MealGroup: Identifiable, Equatable {
    let id: UUID
    var name: String
    var foodIDs: [UUID]
    var colour: String
}

extension MockData {
    static let sampleMealGroup: MealGroup = .init(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Breakfast",
        foodIDs: [
            sampleFoodItem.foodItemID,
            foodItemList[4].foodItemID,
            foodItemList[5].foodItemID
        ],
        colour: "#0095ff"
    )
    
    static var mealGroupList: [MealGroup] = [
        sampleMealGroup,
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Lunch",
            foodIDs: [
                foodItemList[1].foodItemID,
                foodItemList[3].foodItemID,
                foodItemList[8].foodItemID
            ],
            colour: "#ffeb3b"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Dinner",
            foodIDs: [
                foodItemList[6].foodItemID,
                foodItemList[9].foodItemID
            ],
            colour: "#ff5252"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Off-the-Shelf",
            foodIDs: [
                foodItemList[1].foodItemID,
                foodItemList[2].foodItemID,
                foodItemList[7].foodItemID
            ],
            colour: "#a319ff"),
       // .init(
       //     id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
       //     name: "Generated Foods",
       //     foodIDs: Array(foodItemList.map(\.self.foodItemID).dropFirst(10)),
       //     colour: "#4caf50"
       // )
    ]
}
