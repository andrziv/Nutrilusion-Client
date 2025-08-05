//
//  FoodItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

// Used for both Recipes and Ingredients
struct FoodItem {
    let id: UUID = UUID()
    var name: String
    var calories: Int
    var nutritionList: [NutrientItem] = []
    var ingredientList: [FoodItem] = []
    var servingAmount: Double = 1.0
    var servingUnit: String = "x"
    var servingUnitMultiple: String = "x"
    
    func getNutrientValue(_ nutrientType: String) -> NutrientItem? {
        for nutrient in nutritionList {
            if nutrient.name == nutrientType {
                return nutrient
            } else if let childNutrient = nutrient.getChildNutrientValue(nutrientType) {
                return childNutrient
            }
        }
        return nil
    }
}

struct MockData {
    static let sampleFoodItem = FoodItem(
        name: "Peanut Butter Sandwich",
        calories: 350,
        nutritionList: [
            NutrientItem(name: "Protein", amount: 12.0, unit: "g"),
            NutrientItem(name: "Fat", amount: 18.0, unit: "g",
                         childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                          NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
            NutrientItem(name: "Carbohydrates", amount: 30.0, unit: "g",
                         childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                          NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
        ],
        ingredientList: [
            FoodItem(name: "Bread Slice", calories: 120),
            FoodItem(name: "Peanut Butter", calories: 230)
        ],
        servingAmount: 1.0,
        servingUnit: "sandwich",
        servingUnitMultiple: "sandwiches"
    )
    
    static let foodItemList: [FoodItem] = [
        sampleFoodItem,
        FoodItem(
            name: "Greek Yogurt",
            calories: 150,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 15.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 4.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 8.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            servingAmount: 1.0,
            servingUnit: "cup",
            servingUnitMultiple: "cups"
        ),
        FoodItem(
            name: "Apple",
            calories: 95,
            nutritionList: [
                NutrientItem(name: "Carbohydrates", amount: 25.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 4.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            servingAmount: 1.0,
            servingUnit: "x"
        ),
        FoodItem(
            name: "Lasagna",
            calories: 450,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 20.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 25.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Pasta Sheets", calories: 150),
                FoodItem(name: "Ground Beef", calories: 200),
                FoodItem(name: "Tomato Sauce", calories: 50),
                FoodItem(name: "Cheese", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "slice",
            servingUnitMultiple: "slices"
        ),
        FoodItem(
            name: "Chicken Salad",
            calories: 320,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 28.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 18.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 10.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Grilled Chicken", calories: 180),
                FoodItem(name: "Mixed Greens", calories: 30),
                FoodItem(name: "Dressing", calories: 110)
            ],
            servingAmount: 1.0,
            servingUnit: "bowl",
            servingUnitMultiple: "bowls"
        ),
        FoodItem(
            name: "Oatmeal with Banana",
            calories: 270,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 6.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 5.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 50.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Oats", calories: 150),
                FoodItem(name: "Banana", calories: 90),
                FoodItem(name: "Milk", calories: 30)
            ],
            servingAmount: 1.0,
            servingUnit: "bowl",
            servingUnitMultiple: "bowls"
        ),
        FoodItem(
            name: "Cheeseburger",
            calories: 500,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 25.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 30.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Beef Patty", calories: 220),
                FoodItem(name: "Cheese Slice", calories: 80),
                FoodItem(name: "Burger Bun", calories: 150),
                FoodItem(name: "Lettuce & Tomato", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "burger",
            servingUnitMultiple: "burgers"
        ),
        FoodItem(
            name: "Smoothie (Berry Blast)",
            calories: 200,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 5.0, unit: "g"),
                NutrientItem(name: "Carbohydrates", amount: 40.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 5.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Strawberries", calories: 50),
                FoodItem(name: "Blueberries", calories: 60),
                FoodItem(name: "Banana", calories: 80),
                FoodItem(name: "Almond Milk", calories: 10)
            ],
            servingAmount: 350.0,
            servingUnit: "mL",
            servingUnitMultiple: "mL"
            
        ),
        FoodItem(
            name: "Spaghetti Bolognese",
            calories: 550,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 22.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 20.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 60.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Spaghetti", calories: 200),
                FoodItem(name: "Bolognese Sauce", calories: 250),
                FoodItem(name: "Parmesan", calories: 100)
            ],
            servingAmount: 1.0,
            servingUnit: "plate",
            servingUnitMultiple: "plates"
        ),
        FoodItem(
            name: "Veggie Wrap",
            calories: 280,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 8.0, unit: "g"),
                NutrientItem(name: "Fat", amount: 10.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: "g")]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: "g",
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: "g"),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: "g")])
            ],
            ingredientList: [
                FoodItem(name: "Tortilla", calories: 130),
                FoodItem(name: "Grilled Vegetables", calories: 100),
                FoodItem(name: "Hummus", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "wrap",
            servingUnitMultiple: "wraps"
        )
    ]
}

