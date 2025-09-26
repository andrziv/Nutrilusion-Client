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
        Dictionary(foods.map { ($0.foodItemID, $0) }, uniquingKeysWith: { $1 })
    }
    
    private let repository: NutriToolFoodRepositoryProtocol
    
    init(repository: NutriToolFoodRepositoryProtocol) {
        self.repository = repository
        
        loadData()
    }
    
    private func loadData() {
        repository.foodsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$foods)
        
        repository.mealGroupsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$mealGroups)
    }
    
    // MARK: - Group Operations
    func addGroup(_ group: MealGroup) {
        repository.addMealGroup(group)
    }
    
    func updateGroup(_ group: MealGroup) {
        repository.updateMealGroup(group)
    }
    
    func deleteGroup(_ group: MealGroup) {
        repository.deleteMealGroup(group)
    }
    
    func foods(in group: MealGroup) -> [FoodItem] {
        group.foodIDs.compactMap { foodByID[$0] }
    }
    
    func group(for foodItem: FoodItem) -> MealGroup? {
        return mealGroups.first { $0.foodIDs.contains(foodItem.foodItemID) }
    }
    
    // MARK: - Food Operations
    func addFood(_ food: FoodItem, to group: MealGroup) {
        repository.addFood(food, to: group)
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        repository.removeFood(food, from: group)
    }
    
    func updateFood(_ food: FoodItem) {
        repository.updateFood(food)
    }
    
    // MARK: - Food Item Ownership Operations
    func moveFood(_ food: FoodItem, from oldGroup: MealGroup, to newGroup: MealGroup) {
        repository.moveFood(food, from: oldGroup, to: newGroup)
    }
    
    func currentVersionOf(foodItemID: UUID) -> Int {
        return foodByID[foodItemID]?.version ?? 0
    }
}

