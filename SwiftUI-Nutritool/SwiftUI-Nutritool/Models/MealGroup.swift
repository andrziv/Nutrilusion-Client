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
            sampleFoodItem.id,
            foodItemList[4].id,
            foodItemList[5].id
        ],
        colour: "#0095ff"
    )
    
    static var mealGroupList: [MealGroup] = [
        sampleMealGroup,
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Lunch",
            foodIDs: [
                foodItemList[1].id,
                foodItemList[3].id,
                foodItemList[8].id
            ],
            colour: "#ffeb3b"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Dinner",
            foodIDs: [
                foodItemList[6].id,
                foodItemList[9].id
            ],
            colour: "#ff5252"
        ),
        .init(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Off-the-Shelf",
            foodIDs: [
                foodItemList[1].id,
                foodItemList[2].id,
                foodItemList[7].id
            ],
            colour: "#a319ff"),
       // .init(
       //     id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
       //     name: "Generated Foods",
       //     foodIDs: Array(foodItemList.map(\.self.id).dropFirst(10)),
       //     colour: "#4caf50"
       // )
    ]
}
