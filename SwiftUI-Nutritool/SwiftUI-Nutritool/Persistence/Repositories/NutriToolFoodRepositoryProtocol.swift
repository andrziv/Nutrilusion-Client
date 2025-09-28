//
//  NutriToolFoodRepositoryProtocol.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import Foundation
import Combine

protocol NutriToolFoodRepositoryProtocol {
    var foodsPublisher: AnyPublisher<[FoodItem], Never> { get }
    var mealGroupsPublisher: AnyPublisher<[MealGroup], Never> { get }
    
    // Foods
    func addFood(_ food: FoodItem, to group: MealGroup)
    func removeFood(_ food: FoodItem, from group: MealGroup)
    func updateFood(_ food: FoodItem)
    func moveFood(_ food: FoodItem, from oldGroup: MealGroup, to newGroup: MealGroup)
    
    // MealGroups
    func addMealGroup(_ group: MealGroup)
    func updateMealGroup(_ group: MealGroup)
    func deleteMealGroup(_ group: MealGroup)
}

