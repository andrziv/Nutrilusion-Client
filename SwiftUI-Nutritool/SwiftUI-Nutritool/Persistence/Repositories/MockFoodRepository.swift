//
//  MockFoodRepository.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import Combine

class MockFoodRepository: NutriToolFoodRepositoryProtocol {
    private let loggedItemsSubject = CurrentValueSubject<[LoggedMealItem], Never>([])
    private let foodsSubject = CurrentValueSubject<[FoodItem], Never>([])
    private let mealGroupsSubject = CurrentValueSubject<[MealGroup], Never>([])

    var loggedItemsPublisher: AnyPublisher<[LoggedMealItem], Never> {
        loggedItemsSubject.eraseToAnyPublisher()
    }
    
    var foodsPublisher: AnyPublisher<[FoodItem], Never> {
        foodsSubject.eraseToAnyPublisher()
    }

    var mealGroupsPublisher: AnyPublisher<[MealGroup], Never> {
        mealGroupsSubject.eraseToAnyPublisher()
    }

    private var loggedItems: [LoggedMealItem] = []
    private var foods: [FoodItem] = []
    private var mealGroups: [MealGroup] = []
    
    init(foods: [FoodItem] = MockData.foodItemList,
         loggedMealItems: [LoggedMealItem] = MockData.loggedMeals,
         mealGroups: [MealGroup] = MockData.mealGroupList) {
        self.foods = foods
        self.loggedItems = loggedMealItems
        self.mealGroups = mealGroups
        publish()
    }
    
    // MARK: - LoggedMealItewms
    func addLoggedItem(_ meal: LoggedMealItem) {
        loggedItems.append(meal)
        publish()
    }
    
    func removeLoggedItem(_ meal: LoggedMealItem) {
        loggedItems.removeAll { $0.id == meal.id }
        publish()
    }
    
    func updateLoggedItem(_ meal: LoggedMealItem) {
        if let index = loggedItems.firstIndex(where: { $0.id == meal.id }) {
            loggedItems[index] = meal
        }
        publish()
    }
    
    // MARK: - Foods
    func addFood(_ food: FoodItem, to group: MealGroup) {
        foods.append(food)
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.append(food.foodItemID)
        }
        publish()
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        foods.removeAll { $0.id == food.id }
        if let index = mealGroups.firstIndex(where: { $0.id == group.id }) {
            mealGroups[index].foodIDs.removeAll { $0 == food.foodItemID }
        }
        publish()
    }
    
    func updateFood(_ food: FoodItem) {
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            var updatedFood = food
            updatedFood.withVersion(food.version + 1)
            foods[index] = updatedFood
        }
        publish()
    }
    
    func moveFood(_ food: FoodItem, from oldGroup: MealGroup, to newGroup: MealGroup) {
        removeFood(food, from: oldGroup)
        addFood(food, to: newGroup)
    }
    
    // MARK: - MealGroups
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
        let items = foods.filter { group.foodIDs.contains($0.foodItemID) }
        if let offset = offset {
            return Array(items.dropFirst(offset).prefix(limit ?? items.count))
        }
        return items
    }
    
    private func publish() {
        loggedItemsSubject.send(loggedItems)
        foodsSubject.send(foods)
        mealGroupsSubject.send(mealGroups)
    }
}

