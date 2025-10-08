//
//  FoodItem.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

// Used for both Recipes and Ingredients
struct FoodItem: Identifiable, Equatable, Codable {
    var id: String
    let foodItemID: UUID
    var version: Int
    var name: String
    var calories: Int
    var nutritionList: [NutrientItem]
    var ingredientList: [IngredientEntry]
    var servingAmount: Double
    var servingUnit: String
    var servingUnitMultiple: String
    
    init(compositeID: String? = nil, id: UUID = UUID(), version: Int = 0,
         name: String, calories: Int = 0,
         nutritionList: [NutrientItem] = [], ingredientList: [IngredientEntry] = [],
         servingAmount: Double = 1.0, servingUnit: String = "x", servingUnitMultiple: String = "x") {
        if let compositeID = compositeID {
            self.id = compositeID
        } else {
            self.id = compositeId(id, version: version)
        }
        self.foodItemID = id
        self.version = version
        self.name = name
        self.calories = calories
        self.nutritionList = nutritionList
        self.ingredientList = ingredientList
        self.servingAmount = servingAmount
        self.servingUnit = servingUnit
        self.servingUnitMultiple = servingUnitMultiple
    }
    
    /**
     Gets a NutrientItem with the given name from this FoodItem. Child nutrients of held nutrients are also searched for.
     - Parameters:
     - nutrientType: The nutrient to get.
     - Returns: `A NutrientItem with the given name` if one is held by this FoodItem, `nil` otherwise.
     */
    func getNutrient(_ nutrientType: String) -> NutrientItem? {
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
    
    /// Gets a flattened list of all the nutrients held by this FoodItem.
    /// - Returns: An array of all nutrients.
    func getAllNutrients() -> [NutrientItem] {
        var allNutrients: [NutrientItem] = []
        for nutrient in nutritionList {
            allNutrients.append(nutrient)
            allNutrients.append(contentsOf: nutrient.flattenChildren())
        }
        return allNutrients
    }
    
    /**
     Create a nutrient using proper nutrient hierarchical structure.
     - Parameters:
       - nutrientToAdd: The nutrient to create.
     - Returns: True if the item was newly created, false otherwise
     */
    @discardableResult
    mutating func createNutrientChain(_ nutrientToAdd: String) -> Bool {
        return createNutrientChain(NutrientItem(name: nutrientToAdd))
    }
    
    /**
     Create a nutrient using proper nutrient hierarchical structure.
     - Parameters:
       - nutrientToAdd: The nutrient to create.
       - sumNutrients: Determines if the added nutrient should add its values to every parent this nutrient will be a child to.
     - Returns: True if the item was newly created, false otherwise
     */
    @discardableResult
    mutating func createNutrientChain(_ nutrientToAdd: NutrientItem, propagateAmounts: Bool = true) -> Bool {
        guard NutrientTree.shared.findNutrient(nutrientToAdd.name) != nil else {
            print("Nutrient \(nutrientToAdd.name) not found in NutrientTree.")
            return false
        }
        
        for i in nutritionList.indices {
            let result = nutritionList[i].add(nutrientToAdd, propagateChanges: propagateAmounts, adjustAmounts: false, directInsert: false)
            if result {
                return false
            }
        }
        
        // new chain from scratch
        let parents = NutrientTree.shared.getParents(of: nutrientToAdd.name, ignoringGenerics: true)
        let chain = parents + [nutrientToAdd.name]
        let result = addDirectNutrientChain(nutrientToAdd, nameChain: chain)
        return result
    }
    
    private mutating func addDirectNutrientChain(_ nutrientToAdd: NutrientItem, nameChain: [String]) -> Bool {
        if var nutrientChain = generateNutrientItemChain(nameChain) {
            nutrientChain.modify(nutrientToAdd.name, newValue: nutrientToAdd.amount, newUnit: nutrientToAdd.unit)
            
            let order = NutrientTree.shared.getChildOrder(of: "Nutrients", ignoringGenerics: true)
            if !order.isEmpty, let idx = findInsertIndex(for: nutrientChain.name, order: order) {
                nutritionList.insert(nutrientChain, at: idx)
            } else {
                nutritionList.append(nutrientChain)
            }
            
            return true
        }
        
        return false
    }
    
    /// find index to insert child based on config order
    private func findInsertIndex(for childName: String, order: [String]) -> Int? {
        guard let desiredIndex = order.firstIndex(of: childName) else { return nil }
        
        for (i, existing) in nutritionList.enumerated() {
            if let existingIdx = order.firstIndex(of: existing.name), existingIdx > desiredIndex {
                return i
            }
        }
        
        return nil
    }
    
    /**
     Modify a nutrient by name from this item's nutrition list. Value changes will propagate upwards if the nutrient is a child to another nutrient.
     - Parameters:
     - targetName: The nutrient to remove.
         - newValue: Change the value of the nutrient with the given name. If the value is between a certain threshold, the unit will automatically change unless a newUnit value is given.
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
         - newUnit: Change the value of the unit.
     - Returns: `true` if modification occurred, `false` otherwise.
     */
    @discardableResult
    mutating func modifyNutrient(_ targetName: String, newValue: Double? = nil, newUnit: NutrientUnit? = nil, propagateChanges: Bool) -> Bool {
        for i in nutritionList.indices {
            if nutritionList[i].name == targetName {
                nutritionList[i].modify(targetName, newValue: newValue, newUnit: newUnit, propagateChanges: propagateChanges)
                return true
            }
        }
        
        for i in nutritionList.indices {
            if nutritionList[i].modify(targetName, newValue: newValue, newUnit: newUnit, propagateChanges: propagateChanges) {
                return true
            }
        }
        
        return false
    }
    
    /**
     Delete a nutrient by name from this item's nutrition list. Nutrient values are subtracted from parent nutrients if a nutrient is successfully deleted.
     - Parameters:
        - targetName: The nutrient to remove.
        - adjustAmounts: If set, deleting a nutrient will cause a cascading removal of its value from all of the parents of this Nutrient
     - Returns: `true` if deletion occurred, `false` otherwise.
     */
    @discardableResult
    mutating func deleteNutrient(_ targetName: String, adjustAmounts: Bool = true) -> Bool {
        for i in nutritionList.indices {
            if nutritionList[i].name == targetName {
                nutritionList.remove(at: i)
                return true
            }
        }
        
        for i in nutritionList.indices {
            if nutritionList[i].deleteChildNutrient(targetName, adjustAmounts: adjustAmounts, optimizeUnit: true) {
                return true
            }
        }
        
        return false
    }
    
    /**
     Recalculate a nutrient's values from its children.
     - Parameters:
        - targetNames: The nutrient(s) to recalculate.
     */
    mutating func recalculateNutrients(_ targetNames: [String]) {
        for name in targetNames {
            if var target = getNutrient(name) {
                target.recalculateTree()
                replaceNutrient(target)
            }
        }
    }
    
    /// Add a FoodItem ingredient to this FoodItem.
    /// - Parameters:
    ///   - ingredient: The Fooditem ingredient to add.
    ///   - addNutrients: If set to `true`, the addition of the ingredient will result in the ingredient's nutrients being added to the caller's nutrition info. If a nutrient does not exist within the caller's nutrient tree, the nutrient will be added outright.
    mutating func addIngredient(_ ingredient: FoodItem, addNutrients: Bool = true) {
        ingredientList.append(IngredientEntry(ingredient: ingredient, servingMultiplier: 1))
        
        modifyCaloriesBy(amount: ingredient.calories)
        
        if addNutrients {
            for nutrient in ingredient.nutritionList {
                if let index = nutritionList.firstIndex(where: { $0.name == nutrient.name }) {
                    nutritionList[index].add(nutrient, propagateChanges: false, mergeChildren: true)
                } else {
                    nutritionList.append(nutrient.createNewUniqueCopy())
                }
            }
        }
    }
    
    /// Add a FoodItem ingredient to this FoodItem.
    /// - Parameters:
    ///   - ingredient: The IngredientEntry ingredient to modify.
    ///   - oldMultiplier: The old multiplier for the contained ingredient FoodItem serving amount
    ///   - newMultiplier: The new multiplier for the contained ingredient FoodItem serving amount
    mutating func modifyIngredient(_ ingredient: IngredientEntry, oldMultiplier: Double, newMultiplier: Double) {
        guard ingredientList.first(where: { $0.id == ingredient.id }) != nil else { return }
        
        let difference = newMultiplier - oldMultiplier
        let amountToModifyCaloriesBy = difference * Double(ingredient.ingredient.calories)
        modifyCaloriesBy(amount: amountToModifyCaloriesBy)
        
        for nutrient in ingredient.ingredient.getAllNutrients() {
            for index in nutritionList.indices {
                if nutritionList[index].name == nutrient.name {
                    let newAmount = difference * nutrient.amount + nutritionList[index].amount
                    nutritionList[index].modify(nutrient.name, newValue: newAmount, propagateChanges: false)
                } else if let childNutrient = nutritionList[index].getChildNutrientValue(nutrient.name) {
                    let newAmount = difference * nutrient.amount + childNutrient.amount
                    nutritionList[index].modify(nutrient.name, newValue: newAmount, propagateChanges: false)
                }
            }
        }
    }
    
    /// Removes a FoodItem ingredient from this FoodItem.
    /// - Parameters:
    ///   - ingredient: The Fooditem ingredient to remove. Ingredients are compared by ID.
    ///   - subtractNutrients: If set to `true` and the ingredient is held by the caller, the removal of the ingredient will result in the ingredient's nutrients being subtracted from the caller's nutrition info. If a nutrient ends at zero value, the nutrient will not be automatically removed.
    mutating func removeIngredient(_ ingredient: IngredientEntry, subtractNutrients: Bool = true) {
        guard let existsAtIndex = ingredientList.firstIndex(where: { $0.id == ingredient.id }) else { return }
        
        ingredientList.remove(at: existsAtIndex)
        
        let amountToModifyCaloriesBy = -ingredient.servingMultiplier * Double(ingredient.ingredient.calories)
        modifyCaloriesBy(amount: amountToModifyCaloriesBy)
        
        if subtractNutrients {
            for nutrient in ingredient.ingredient.nutritionList {
                if let index = nutritionList.firstIndex(where: { $0.name == nutrient.name }) {
                    nutritionList[index].subtract(nutrient, multiplier: ingredient.servingMultiplier)
                } else {
                    continue
                }
            }
        }
    }
    
    /// Checks if this FoodItem contains a given ingredient, either directly or within nested child ingredients.
    /// - Parameter ingredient: The ingredient to search for.
    /// - Returns: `true` if the ingredient is found anywhere within this FoodItem, `false` otherwise.
    func containsIngredient(_ ingredient: FoodItem) -> Bool {
        // direct match
        if ingredientList.contains(where: { $0.ingredient.id == ingredient.id }) {
            return true
        }
        
        // recursive search
        for child in ingredientList {
            if child.ingredient.containsIngredient(ingredient) {
                return true
            }
        }
        
        return false
    }
    
    mutating func withVersion(_ version: Int) {
        self.version = version
        self.id = compositeId(self.foodItemID, version: version)
    }
    
    // just creates a chain of nutrient items corresponding to a given nutrient name array
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
    
    private mutating func replaceNutrient(_ updated: NutrientItem) {
        for i in nutritionList.indices {
            if nutritionList[i].name == updated.name {
                nutritionList[i] = updated
                return
            }
            if let idx = nutritionList[i].childNutrients.firstIndex(where: { $0.name == updated.name }) {
                nutritionList[i].childNutrients[idx] = updated
                return
            }
        }
    }
    
    private mutating func modifyCaloriesBy(amount: Double) {
        modifyCaloriesBy(amount: Int(amount))
    }
    
    private mutating func modifyCaloriesBy(amount: Int) {
        calories += amount
        calories = max(0, calories)
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
            IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000111")!, name: "Bread Slice", calories: 120), servingMultiplier: 1),
            IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000112")!, name: "Peanut Butter", calories: 230), servingMultiplier: 1)
        ],
        servingAmount: 1.0,
        servingUnit: "sandwich",
        servingUnitMultiple: "sandwiches"
    )
    
    static let foodItemList: [FoodItem] = {
        var items: [FoodItem] = [
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
                    IngredientEntry(ingredient: sampleFoodItem, servingMultiplier: 1),
                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000113")!, name: "Pasta Sheets", calories: 150), servingMultiplier: 1),
                                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000114")!, name: "Ground Beef", calories: 200), servingMultiplier: 1),
                                                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000115")!, name: "Tomato Sauce", calories: 50), servingMultiplier: 1),
                                                                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000116")!,name: "Cheese", calories: 50), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000117")!, name: "Grilled Chicken", calories: 180), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000118")!, name: "Mixed Greens", calories: 30), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000119")!, name: "Dressing", calories: 110), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000120")!, name: "Oats", calories: 150), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000121")!, name: "Banana", calories: 90), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000122")!, name: "Milk", calories: 30), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000123")!, name: "Beef Patty", calories: 220), servingMultiplier: 1),
                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000124")!, name: "Cheese Slice", calories: 80), servingMultiplier: 1),
                                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000125")!, name: "Burger Bun", calories: 150), servingMultiplier: 1),
                                                                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000126")!, name: "Lettuce & Tomato", calories: 50), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000127")!, name: "Strawberries", calories: 50), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000128")!, name: "Blueberries", calories: 60), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000129")!, name: "Banana", calories: 80), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000130")!, name: "Almond Milk", calories: 10), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000131")!, name: "Spaghetti", calories: 200), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000132")!, name: "Bolognese Sauce", calories: 250), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000133")!, name: "Parmesan", calories: 100), servingMultiplier: 1)
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
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000134")!, name: "Tortilla", calories: 130), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000135")!, name: "Grilled Vegetables", calories: 100), servingMultiplier: 1),
                    IngredientEntry(ingredient: FoodItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000136")!, name: "Hummus", calories: 50), servingMultiplier: 1)
                ],
                servingAmount: 1.0,
                servingUnit: "wrap",
                servingUnitMultiple: "wraps"
            )
        ]
        
        for i in 1...50000 {
            let item = FoodItem(
                id: UUID(),
                name: "Generated Food Item \(i)",
                calories: Int.random(in: 50...700),
                nutritionList: [
                    NutrientItem(name: "Protein", amount: Double.random(in: 0...40), unit: .grams),
                    NutrientItem(name: "Fat", amount: Double.random(in: 0...30), unit: .grams),
                    NutrientItem(name: "Carbohydrates", amount: Double.random(in: 0...80), unit: .grams)
                ],
                servingAmount: 1.0,
                servingUnit: "portion",
                servingUnitMultiple: "portions"
            )
            items.append(item)
        }
        
        return items
    }()
}

