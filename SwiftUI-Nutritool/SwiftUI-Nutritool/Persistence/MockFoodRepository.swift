//
//  MockFoodRepository.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import Foundation

class MockFoodRepository: NutriToolFoodRepositoryProtocol {
    private var foods: [FoodItem]
    private var mealGroups: [MealGroup]
    
    init(foods: [FoodItem] = MockData.foodItemList,
         mealGroups: [MealGroup] = MockData.mealGroupList) {
        self.foods = foods
        self.mealGroups = mealGroups
    }
    
    // MARK: - Foods
    func fetchFoods() -> [FoodItem] {
        foods
    }
    
    func addFood(_ food: FoodItem, to group: MealGroup) {
        foods.append(food)
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.append(food.id)
        }
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        foods.removeAll { $0.id == food.id }
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.removeAll { $0 == food.id }
        }
    }
    
    func updateFood(_ food: FoodItem) {
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            foods[index] = food
        }
    }
    
    // MARK: - MealGroups
    func fetchMealGroups() -> [MealGroup] {
        mealGroups
    }
    
    func addMealGroup(_ group: MealGroup) {
        mealGroups.append(group)
    }
    
    func updateMealGroup(_ group: MealGroup) {
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index] = group
        }
    }
    
    func deleteMealGroup(_ group: MealGroup) {
        mealGroups.removeAll { $0.id == group.id }
    }
    
    func fetchFoods(for group: MealGroup, limit: Int? = nil, offset: Int? = nil) -> [FoodItem] {
        let items = foods.filter { group.foodIDs.contains($0.id) }
        if let offset = offset {
            return Array(items.dropFirst(offset).prefix(limit ?? items.count))
        }
        return items
    }
}

