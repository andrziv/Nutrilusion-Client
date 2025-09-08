//
//  FoodItemSearchViewModel.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-02.
//

import Foundation
import Combine
import SwiftUICore

struct FoodItemGroupPair: Identifiable {
    let id: UUID
    let foodItemID: UUID
    let foodItemName: String
    let mealGroupID: UUID
    let mealGroupName: String
    
    init(foodItem: FoodItem, mealGroup: MealGroup) {
        self.id = UUID()
        self.foodItemID = foodItem.id
        self.foodItemName = foodItem.name
        self.mealGroupID = mealGroup.id
        self.mealGroupName = mealGroup.name
    }
}

class FoodItemSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredPairs: [FoodItemGroupPair] = []
    
    private var groups: [MealGroup]
    private let searchDelayTime: Int
    private let resultLimit: Int
    private var cancellables = Set<AnyCancellable>()
    
    private var currentSearchTask: Task<Void, Never>?
    
    init(groups: [MealGroup], searchDelayTime: Int = 300, resultLimit: Int = 100) {
        self.groups = groups
        self.searchDelayTime = searchDelayTime
        self.resultLimit = resultLimit
        setupSearch()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(searchDelayTime), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }
    
    func performSearch(_ query: String) {
        currentSearchTask?.cancel()
        
        guard !query.isEmpty else {
            filteredPairs = []
            return
        }
        
        currentSearchTask = Task(priority: .userInitiated) {
            let results = await Self.search(query: query, in: groups, limit: resultLimit)
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.filteredPairs = results
                }
            }
        }
    }
    
    func resolveBindings(in mealGroups: Binding<[MealGroup]>, for pair: FoodItemGroupPair) -> (foodItem: Binding<FoodItem>, mealGroup: MealGroup)? {
        guard
            let groupIndex = mealGroups.wrappedValue.firstIndex(where: { $0.id == pair.mealGroupID }),
            let foodIndex = mealGroups.wrappedValue[groupIndex].meals.firstIndex(where: { $0.id == pair.foodItemID })
        else {
            return nil
        }
        
        let foodItemBinding = mealGroups[groupIndex].meals[foodIndex]
        let mealGroupValue = mealGroups.wrappedValue[groupIndex]
        return (foodItem: foodItemBinding, mealGroup: mealGroupValue)
    }
    
    func refreshSearch(with newGroups: [MealGroup]) {
        self.groups = newGroups
        performSearch(searchText)
    }
    
    private static func search(query: String, in groups: [MealGroup], limit: Int) async -> [FoodItemGroupPair] {
        var results: [FoodItemGroupPair] = []
        for group in groups {
            for food in group.meals {
                if Task.isCancelled { return [] }
                if food.name.localizedCaseInsensitiveContains(query) {
                    results.append(FoodItemGroupPair(foodItem: food, mealGroup: group))
                    if results.count >= limit { return results }
                }
            }
        }
        return results
    }
}
