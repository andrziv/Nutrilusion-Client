//
//  SearchPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchPopupView: View {
    @Binding var screenMode: RecipeListViewMode
    var mealGroups: [MealGroup]
    
    @State private var searchString: String = ""
    @FocusState private var searchFocus: Bool
    
    var body: some View {
        VStack {
            PopupTextField(textBinding: $searchString, placeholder: "Search for Recipe Names... eg: Lasagna")
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
            
            Button("Dismiss") {
                screenMode = .normal
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
        .ignoresSafeArea(edges: .bottom)
    }
}