//
//  SearchPopupView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct SearchPopupView: View {
    let exitAction: () -> Void
    let itemTapAction: (FoodItem) -> Void
    let allowEditing: Bool
    
    @Binding private var mealGroups: [MealGroup]
    @StateObject private var viewModel: FoodItemSearchViewModel
    @FocusState private var searchFocus: Bool
    
    init(mealGroups: [MealGroup], allowEditing: Bool, exitAction: @escaping () -> Void, itemTapAction: @escaping (FoodItem) -> Void) {
        self.allowEditing = allowEditing
        self.exitAction = exitAction
        self.itemTapAction = itemTapAction
        self._viewModel = StateObject(wrappedValue: FoodItemSearchViewModel(groups: mealGroups))
        self._mealGroups = .constant(mealGroups)
    }
    
    init(mealGroups: Binding<[MealGroup]>, allowEditing: Bool, exitAction: @escaping () -> Void, itemTapAction: @escaping (FoodItem) -> Void) {
        self.allowEditing = allowEditing
        self.exitAction = exitAction
        self.itemTapAction = itemTapAction
        self._viewModel = StateObject(wrappedValue: FoodItemSearchViewModel(groups: mealGroups.wrappedValue))
        self._mealGroups = mealGroups
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
            
            LazyVScroll(items: viewModel.filteredPairs) { pair in
                if let resolved = viewModel.resolveBindings(in: $mealGroups, for: pair) {
                    Button {
                        itemTapAction(resolved.foodItem.wrappedValue)
                    } label: {
                        FoodItemView(
                            foodItem: resolved.foodItem,
                            mealGroup: resolved.mealGroup,
                            editingAllowed: allowEditing
                        )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, action: exitAction)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .basicBackground(shadowRadius: 0, background: .secondaryBackground.opacity(0.5))
        .onChange(of: mealGroups) { _, updatedGroups in
            viewModel.refreshSearch(with: updatedGroups)
        }
    }
}

#Preview {
    SearchPopupView(mealGroups: MockData.mealGroupList, allowEditing: true) {
        
    } itemTapAction: { foodItem in
        
    }
}
