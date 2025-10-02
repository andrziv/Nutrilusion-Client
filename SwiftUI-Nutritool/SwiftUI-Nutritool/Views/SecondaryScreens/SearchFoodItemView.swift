//
//  SearchFoodItemView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchFoodItemView: View {
    @ObservedObject var foodViewModel: NutriToolFoodViewModel
    let exitAction: () -> Void
    let itemTapAction: (MealGroup, FoodItem) -> Void
    let allowEditing: Bool
    
    let isItemDisabled: ((FoodItem) -> Bool)?
    let overlayProvider: ((FoodItem) -> AnyView)?
    
    @StateObject private var searchViewModel: FoodItemSearchViewModel
    @FocusState private var searchFocus: Bool
    
    init(foodViewModel: NutriToolFoodViewModel,
         allowEditing: Bool,
         exitAction: @escaping () -> Void, itemTapAction: @escaping (MealGroup, FoodItem) -> Void,
         isItemDisabled: ((FoodItem) -> Bool)? = nil, overlayProvider: ((FoodItem) -> AnyView)? = nil) {
        self.foodViewModel = foodViewModel
        self.allowEditing = allowEditing
        self.exitAction = exitAction
        self.itemTapAction = itemTapAction
        self.isItemDisabled = isItemDisabled
        self.overlayProvider = overlayProvider
        self._searchViewModel = StateObject(wrappedValue: FoodItemSearchViewModel(foodViewModel: foodViewModel))
    }
    
    var body: some View {
        VStack {
            BasicTextField("Search for Recipe Names... eg: Lasagna", text: $searchViewModel.searchText, outlineWidth: 0, background: .primaryComplement)
                .focused($searchFocus)
                .onAppear {
                    withAnimation {
                        searchFocus = true
                    }
                }
            
            LazyVScroll(items: searchViewModel.results) { foodItem in
                let disabled = isItemDisabled?(foodItem) ?? false
                if let group = foodViewModel.group(for: foodItem) {
                    Button {
                        if !disabled {
                            itemTapAction(group, foodItem)
                        }
                    } label: {
                        ZStack {
                            FoodItemView(
                                foodItem: foodItem,
                                viewModel: foodViewModel,
                                showGroupInfo: true,
                                editingAllowed: allowEditing
                            )
                            .opacity(disabled ? 0.4 : 1.0)
                            
                            if let overlay = overlayProvider?(foodItem) {
                                overlay
                            }
                        }
                    }
                    .disabled(disabled)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, action: exitAction)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .basicBackground(shadowRadius: 0, background: .backgroundColour)
    }
}

#Preview {
    let viewModel = NutriToolFoodViewModel(repository: MockFoodRepository())
    SearchFoodItemView(foodViewModel: viewModel, allowEditing: true) {
        
    } itemTapAction: { mealGroup, foodItem in
        
    }
}
