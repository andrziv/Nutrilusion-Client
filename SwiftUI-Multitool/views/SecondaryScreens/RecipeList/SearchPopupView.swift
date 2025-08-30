//
//  SearchPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchPopupView: View {
    @Binding var screenMode: RecipeListViewMode?
    var mealGroups: [MealGroup]
    
    @State private var searchString: String = ""
    @FocusState private var searchFocus: Bool
    
    var body: some View {
        VStack {
            BasicTextField("Search for Recipe Names... eg: Lasagna", text: $searchString)
                .focused($searchFocus)
                .onAppear {
                    withAnimation {
                        searchFocus = true
                    }
                }
            
            let filteredMeals = mealGroups
                .flatMap(\.meals)
                .filter { $0.name.lowercased().contains(searchString.lowercased()) }
                .reduce(into: [FoodItem]()) { result, meal in
                    if !result.contains(where: { $0.id == meal.id }) {
                        result.append(meal)
                    }
                }
            
            LazyVScroll(items: filteredMeals) { meal in
                FoodItemView(foodItem: meal)
            }
            
            ImagedButton(title: "Dismiss", icon: "xmark", circleColor: .clear, cornerRadius: 10) {
                screenMode = nil
            }
            .frame(maxWidth: .infinity)
        }
        .basicBackground()
    }
}

#Preview {
    SearchPopupView(screenMode: .constant(.addCategory), mealGroups: MockData.mealGroupList)
}
