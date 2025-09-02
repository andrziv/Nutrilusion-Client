//
//  FoodItemSearchViewModel.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-09-02.
//

import Foundation
import Combine

struct FoodItemGroupPair: Identifiable {
    let id = UUID()
    let foodItem: FoodItem
    let mealGroup: MealGroup
}

class FoodItemSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredPairs: [FoodItemGroupPair] = []
    
    private var searchDelayTime: Int = 300
    private var resultLimit: Int = 100
    
    private let mealGroups: [MealGroup]
    private var cancellables = Set<AnyCancellable>()
    
    init(_ mealGroups: [MealGroup], searchDelayTime: Int = 300, resultLimit: Int = 100) {
        self.mealGroups = mealGroups
        self.searchDelayTime = searchDelayTime
        self.resultLimit = resultLimit
        
        $searchText
            .debounce(for: .milliseconds(searchDelayTime), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            DispatchQueue.main.async { self.filteredPairs = [] }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.mealGroups
                .flatMap { group in
                    group.meals.map { FoodItemGroupPair(foodItem: $0, mealGroup: group) }
                }
                .filter { pair in
                    pair.foodItem.name.localizedCaseInsensitiveContains(query)
                }
            
            // limit results for now
            let limited = Array(results.prefix(self.resultLimit))
            DispatchQueue.main.async {
                self.filteredPairs = limited
            }
        }
    }
}
