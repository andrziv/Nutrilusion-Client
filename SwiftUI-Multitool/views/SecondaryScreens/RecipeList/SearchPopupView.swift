//
//  SearchPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchPopupView: View {
    var mealGroups: [MealGroup]
    let action: () -> Void
    
    @StateObject private var viewModel: FoodItemSearchViewModel
    @FocusState private var searchFocus: Bool
    
    init(mealGroups: [MealGroup], action: @escaping () -> Void) {
        self.mealGroups = mealGroups
        self.action = action
        
        self._viewModel = StateObject(wrappedValue: FoodItemSearchViewModel(mealGroups))
    }
    
    var body: some View {
        VStack {
            BasicTextField("Search for Recipe Names... eg: Lasagna", text: $viewModel.searchText)
                .focused($searchFocus)
                .onAppear {
                    withAnimation {
                        searchFocus = true
                    }
                }
            
            LazyVScroll(items: viewModel.filteredPairs) { meal in
                FoodItemView(foodItem: meal.foodItem, mealGroup: meal.mealGroup)
            }
            
            ImagedButton(title: "Dismiss", icon: "xmark", circleColour: .clear, cornerRadius: 10, action: action)
                .frame(maxWidth: .infinity)
        }
        .basicBackground()
    }
}

#Preview {
    SearchPopupView(mealGroups: MockData.mealGroupList) {}
}
