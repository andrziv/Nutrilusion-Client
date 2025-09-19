//
//  NutriToolFoodRepositoryProtocol.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import Foundation

protocol NutriToolFoodRepositoryProtocol {
    // Foods
    func fetchFoods() -> [FoodItem]
    func addFood(_ food: FoodItem, to group: MealGroup)
    func removeFood(_ food: FoodItem, from group: MealGroup)
    func updateFood(_ food: FoodItem)
    
    // MealGroups
    func fetchMealGroups() -> [MealGroup]
    func addMealGroup(_ group: MealGroup)
    func updateMealGroup(_ group: MealGroup)
    func deleteMealGroup(_ group: MealGroup)
    
    // Optimized
    func fetchFoods(for group: MealGroup, limit: Int?, offset: Int?) -> [FoodItem]
}

