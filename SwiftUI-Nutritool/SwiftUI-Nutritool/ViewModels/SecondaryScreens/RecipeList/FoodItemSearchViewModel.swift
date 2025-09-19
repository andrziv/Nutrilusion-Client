//
//  FoodItemSearchViewModel.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-02.
//

import Foundation
import Combine
import SwiftUICore

class FoodItemSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [FoodItem] = []
    
    @ObservedObject private var foodViewModel: NutriToolFoodViewModel
    private let searchDelayTime: Int
    private let resultLimit: Int
    private var cancellables = Set<AnyCancellable>()
    private var currentSearchTask: Task<Void, Never>?

    init(foodViewModel: NutriToolFoodViewModel, searchDelayTime: Int = 300, resultLimit: Int = 100) {
        self.foodViewModel = foodViewModel
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
            results = []
            return
        }
        
        currentSearchTask = Task(priority: .userInitiated) {
            let matches = await Self.search(query: query, in: foodViewModel.foods, limit: resultLimit)
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.results = matches
                }
            }
        }
    }
    
    private static func search(query: String, in foods: [FoodItem], limit: Int) async -> [FoodItem] {
        var results: [FoodItem] = []
        
        for food in foods {
            if Task.isCancelled { return [] }
            if food.name.localizedCaseInsensitiveContains(query) {
                results.append(food)
                if results.count >= limit { return results }
            }
        }
        return results
    }
}
