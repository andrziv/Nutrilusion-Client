//
//  SearchPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchPopupView: View {
    var mealGroups: [MealGroup]
    let exitAction: () -> Void
    let itemTapAction: (FoodItem) -> Void
    
    @StateObject private var viewModel: FoodItemSearchViewModel
    @FocusState private var searchFocus: Bool
    
    init(mealGroups: [MealGroup], exitAction: @escaping () -> Void, itemTapAction: @escaping (FoodItem) -> Void) {
        self.mealGroups = mealGroups
        self.exitAction = exitAction
        self.itemTapAction = itemTapAction
        
        self._viewModel = StateObject(wrappedValue: FoodItemSearchViewModel(mealGroups))
    }
    
    var body: some View {
        VStack {
            BasicTextField("Search for Recipe Names... eg: Lasagna", text: $viewModel.searchText, outlineWidth: 0, background: .secondaryBackground)
                .focused($searchFocus)
                .onAppear {
                    withAnimation {
                        searchFocus = true
                    }
                }
            
            LazyVScroll(items: viewModel.filteredPairs) { meal in
                Button {
                    itemTapAction(meal.foodItem)
                } label: {
                    FoodItemView(foodItem: meal.foodItem, mealGroup: meal.mealGroup)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            ImagedButton(title: "Dismiss", icon: "xmark", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, action: exitAction)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .basicBackground(shadowRadius: 0, background: .secondaryBackground.opacity(0.5))
    }
}

#Preview {
    SearchPopupView(mealGroups: MockData.mealGroupList) {
        
    } itemTapAction: { foodItem in
        
    }
}
