//
//  FoodItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

// Used for both Recipes and Ingredients
struct FoodItem: Identifiable {
    let id: UUID
    var name: String
    var calories: Int
    var nutritionList: [NutrientItem]
    var ingredientList: [FoodItem]
    var servingAmount: Double
    var servingUnit: String
    var servingUnitMultiple: String
    
    init(id: UUID = UUID(), name: String, calories: Int = 0,
         nutritionList: [NutrientItem] = [], ingredientList: [FoodItem] = [],
         servingAmount: Double = 1.0, servingUnit: String = "x", servingUnitMultiple: String = "x") {
        self.id = id
        self.name = name
        self.calories = calories
        self.nutritionList = nutritionList
        self.ingredientList = ingredientList
        self.servingAmount = servingAmount
        self.servingUnit = servingUnit
        self.servingUnitMultiple = servingUnitMultiple
    }
    
    func getNutrientValue(_ nutrientType: String) -> NutrientItem? {
        for nutrient in nutritionList {
            if nutrient.name == nutrientType {
                return nutrient
            }
        }
        
        for nutrient in nutritionList {
            if let childNutrient = nutrient.getChildNutrientValue(nutrientType) {
                return childNutrient
            }
        }
        
        return nil
    }
    
    func getAllNutrients() -> [NutrientItem] {
        var allNutrients: [NutrientItem] = []
        for nutrient in nutritionList {
            allNutrients.append(nutrient)
            allNutrients.append(contentsOf: nutrient.flattenChildren())
        }
        return allNutrients
    }
    
    /// Create a nutrient by name using proper nutrient hierarchical structure.
    /// - Parameters:
    ///   - nutrientToAdd: The nutrient to create.
    mutating func createNutrientChain(_ nutrientToAdd: String) {
        var nameChain: [String] = NutrientTree.shared.getParents(of: nutrientToAdd, ignoringGenerics: true)
        
        for nutrientName in nameChain {
            for index in 0..<nutritionList.count {
                if nutritionList[index].name == nutrientName {
                    nutritionList[index].appendChildNutrient(NutrientItem(name: nutrientToAdd))
                    return
                }
            }
        }
        
        nameChain.append(nutrientToAdd)
        if let nutrientChain = generateNutrientItemChain(nameChain) {
            nutritionList.append(nutrientChain)
        }
    }
    
    @discardableResult
    mutating func modifyNutrient(_ targetName: String, newValue: Double? = nil, newUnit: NutrientUnit? = nil) -> Bool {
        for i in nutritionList.indices {
            if nutritionList[i].name == targetName {
                nutritionList[i].modify(targetName, newValue: newValue, newUnit: newUnit)
                return true
            }
        }
        
        for i in nutritionList.indices {
            if nutritionList[i].modify(targetName, newValue: newValue, newUnit: newUnit) {
                return true
            }
        }
        
        return false
    }
    
    /// Delete a nutrient by name from this node’s children (recursively).
    /// - Parameters:
    ///   - targetName: The nutrient to remove.
    /// - Returns: `true` if deletion occurred, `false` otherwise.
    @discardableResult mutating func deleteNutrient(_ targetName: String) -> Bool {
        for i in nutritionList.indices {
            if nutritionList[i].name == targetName {
                nutritionList.remove(at: i)
                return true
            }
        }
        
        for i in nutritionList.indices {
            if nutritionList[i].deleteChildNutrient(targetName, adjustAmounts: true) {
                return true
            }
        }
        
        return false
    }
    
    private func generateNutrientItemChain(_ nutrientToChain: [String]) -> NutrientItem? {
        if nutrientToChain.isEmpty {
            return nil
        }
        
        var nutrientItemParent = NutrientItem(name: nutrientToChain.first!)
        if nutrientToChain.count > 1 {
            if let nutrientItemChild = generateNutrientItemChain(Array(nutrientToChain.suffix(from: 1))) {
                nutrientItemParent.childNutrients.append(nutrientItemChild)
            }
        }
        
        return nutrientItemParent
    }
}

struct MockData {
    static let sampleFoodItem = FoodItem(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
        name: "Peanut Butter Sandwich",
        calories: 350,
        nutritionList: [
            NutrientItem(name: "Protein",
                         amount: 12.0,
                         unit: .grams),
            NutrientItem(name: "Fat",
                         amount: 14.0,
                         unit: .grams,
                         childNutrients: [
                            NutrientItem(name: "Trans Fat",
                                         amount: 0.0,
                                         unit: .grams),
                            NutrientItem(name: "Saturated Fat",
                                         amount: 1.0,
                                         unit: .grams),
                            NutrientItem(name: "Unsaturated Fat",
                                         amount: 13.0,
                                         unit: .grams,
                                         childNutrients: [
                                            NutrientItem(name: "Monounsaturated",
                                                         amount: 2.0,
                                                         unit: .grams),
                                            NutrientItem(name: "Polyunsaturated",
                                                         amount: 11.0,
                                                         unit: .grams,
                                                         childNutrients: [
                                                            NutrientItem(name: "Omega-3",
                                                                         amount: 5.0,
                                                                         unit: .grams),
                                                            NutrientItem(name: "Omega-6", amount: 6.0, unit: .grams)
                                                         ]
                                                        )
                                         ]
                                        )
                         ]
                        ),
            NutrientItem(name: "Carbohydrates", amount: 30.0, unit: .grams,
                         childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                          NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
        ],
        ingredientList: [
            FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000111")!, name: "Bread Slice", calories: 120),
            FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000112")!, name: "Peanut Butter", calories: 230)
        ],
        servingAmount: 1.0,
        servingUnit: "sandwich",
        servingUnitMultiple: "sandwiches"
    )
    
    static let foodItemList: [FoodItem] = [
        sampleFoodItem,
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            name: "Greek Yogurt",
            calories: 150,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 15.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 4.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 8.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            servingAmount: 1.0,
            servingUnit: "cup",
            servingUnitMultiple: "cups"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
            name: "Apple",
            calories: 95,
            nutritionList: [
                NutrientItem(name: "Carbohydrates", amount: 25.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 4.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            servingAmount: 1.0,
            servingUnit: "x"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
            name: "Lasagna",
            calories: 450,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 20.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 25.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000113")!, name: "Pasta Sheets", calories: 150),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000114")!, name: "Ground Beef", calories: 200),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000115")!, name: "Tomato Sauce", calories: 50),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000116")!,name: "Cheese", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "slice",
            servingUnitMultiple: "slices"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
            name: "Chicken Salad",
            calories: 320,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 28.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 18.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 10.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000117")!, name: "Grilled Chicken", calories: 180),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000118")!, name: "Mixed Greens", calories: 30),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000119")!, name: "Dressing", calories: 110)
            ],
            servingAmount: 1.0,
            servingUnit: "bowl",
            servingUnitMultiple: "bowls"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
            name: "Oatmeal with Banana",
            calories: 270,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 6.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 5.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 50.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000120")!, name: "Oats", calories: 150),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000121")!, name: "Banana", calories: 90),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000122")!, name: "Milk", calories: 30)
            ],
            servingAmount: 1.0,
            servingUnit: "bowl",
            servingUnitMultiple: "bowls"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!,
            name: "Cheeseburger",
            calories: 500,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 25.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 30.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000123")!, name: "Beef Patty", calories: 220),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000124")!, name: "Cheese Slice", calories: 80),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000125")!, name: "Burger Bun", calories: 150),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000126")!, name: "Lettuce & Tomato", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "burger",
            servingUnitMultiple: "burgers"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!,
            name: "Smoothie (Berry Blast)",
            calories: 200,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 5.0, unit: .grams),
                NutrientItem(name: "Carbohydrates", amount: 40.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 5.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000127")!, name: "Strawberries", calories: 50),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000128")!, name: "Blueberries", calories: 60),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000129")!, name: "Banana", calories: 80),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000130")!, name: "Almond Milk", calories: 10)
            ],
            servingAmount: 350.0,
            servingUnit: "mL",
            servingUnitMultiple: "mL"
            
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!,
            name: "Spaghetti Bolognese",
            calories: 550,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 22.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 20.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 60.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000131")!, name: "Spaghetti", calories: 200),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000132")!, name: "Bolognese Sauce", calories: 250),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000133")!, name: "Parmesan", calories: 100)
            ],
            servingAmount: 1.0,
            servingUnit: "plate",
            servingUnitMultiple: "plates"
        ),
        FoodItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            name: "Veggie Wrap",
            calories: 280,
            nutritionList: [
                NutrientItem(name: "Protein", amount: 8.0, unit: .grams),
                NutrientItem(name: "Fat", amount: 10.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Trans Fat", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Saturated Fat", amount: 1.0, unit: .grams)]),
                NutrientItem(name: "Carbohydrates", amount: 35.0, unit: .grams,
                             childNutrients: [NutrientItem(name: "Dietary Fiber", amount: 0.0, unit: .grams),
                                              NutrientItem(name: "Sugar", amount: 1.0, unit: .grams)])
            ],
            ingredientList: [
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000134")!, name: "Tortilla", calories: 130),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000135")!, name: "Grilled Vegetables", calories: 100),
                FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000136")!, name: "Hummus", calories: 50)
            ],
            servingAmount: 1.0,
            servingUnit: "wrap",
            servingUnitMultiple: "wraps"
        )
    ]
}

