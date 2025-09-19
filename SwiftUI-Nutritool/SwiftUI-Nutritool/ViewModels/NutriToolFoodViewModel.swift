//
//  NutriToolFoodViewModel.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import SwiftUI
import Combine

@MainActor
final class NutriToolFoodViewModel: ObservableObject {
    @Published private(set) var foods: [FoodItem] = []
    @Published private(set) var mealGroups: [MealGroup] = []
    
    var foodByID: [UUID: FoodItem] {
        Dictionary(foods.map { ($0.id, $0) }, uniquingKeysWith: { $1 })
    }
    
    private let repository: NutriToolFoodRepositoryProtocol
    
    init(repository: NutriToolFoodRepositoryProtocol) {
        self.repository = repository
        loadData()
    }
    
    func loadData() {
        self.foods = repository.fetchFoods()
        self.mealGroups = repository.fetchMealGroups()
    }
    
    // MARK: - Group Operations
    func addGroup(_ group: MealGroup) {
        repository.addMealGroup(group)
        mealGroups.append(group)
    }
    
    func updateGroup(_ group: MealGroup) {
        repository.updateMealGroup(group)
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index] = group
        }
    }
    
    func deleteGroup(_ group: MealGroup) {
        repository.deleteMealGroup(group)
        mealGroups.removeAll { $0.id == group.id }
    }
    
    func foods(in group: MealGroup) -> [FoodItem] {
        group.foodIDs.compactMap { foodByID[$0] }
    }
    
    func group(for foodItem: FoodItem) -> MealGroup? {
        return mealGroups.first { $0.foodIDs.contains(foodItem.id) }
    }
    
    // MARK: - Food Operations
    func addFood(_ food: FoodItem, to group: MealGroup) {
        repository.addFood(food, to: group)
        foods.append(food)
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.append(food.id)
        }
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        repository.removeFood(food, from: group)
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.removeAll { $0 == food.id }
        }
    }
    
    func updateFood(_ food: FoodItem) {
        repository.updateFood(food)

        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            foods[index] = food
        } else {
            foods.append(food)
        }
    }
    
    // MARK: - Food Item Ownership Operations
    func moveFood(_ food: FoodItem, from oldGroup: MealGroup, to newGroup: MealGroup) {
        removeFood(food, from: oldGroup)
        addFood(food, to: newGroup)
    }
}

