//
//  BuilderCreatorModeView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

fileprivate enum BuilderRecipeCreatorMode: Int, CaseIterable {
    case ingredients = 0
    case details
    
    var title: String {
        switch self {
        case .ingredients:
            return "Ingredient Details"
        case .details:
            return "Nutrient Details"
        }
    }
    
    var position: Position {
        switch self {
        case .ingredients:
            return Position.left
        case .details:
            return Position.right
        }
    }
}

struct BuilderCreatorModeView: View {
    @Binding var foodItem: FoodItem
    let mealGroups: [MealGroup]
    @State private var selectedMode: BuilderRecipeCreatorMode = .ingredients
    @State private var showIngredientList: Bool = false
    
    var body: some View {
        VStack {
            BuilderModeSwitcherView(selectedMode: $selectedMode)
            
            if selectedMode == .ingredients {
                IngredientEditorialView(foodItem: $foodItem, mealGroups: mealGroups, showIngredientList: $showIngredientList)
            } else if selectedMode == .details {
                ManualCreatorModeView(foodItem: $foodItem)
            }
        }
        .fullScreenCover(isPresented: $showIngredientList) {
            SearchPopupView(mealGroups: mealGroups, allowEditing: false) {
                self.showIngredientList = false
            } itemTapAction: { newIngredient in
                foodItem.addIngredient(newIngredient)
                self.showIngredientList = false
            }
        }
    }
}

struct IngredientEditorialView: View {
    @Binding var foodItem: FoodItem
    let mealGroups: [MealGroup]
    @Binding var showIngredientList: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                IngredientListEditorialView(foodItem: $foodItem, mealGroups: mealGroups)
            }
            
            Button {
                showIngredientList = true
            } label: {
                DashedButtonView(imageName: "plus")
            }
        }
    }
}

private struct IngredientListEditorialView: View {
    @Binding var foodItem: FoodItem
    let mealGroups: [MealGroup]
    
    private func deleteIngredient(_ ingredient: FoodItem) {
        foodItem.removeIngredient(ingredient)
    }
    
    var body: some View {
        VStack {
            ForEach ($foodItem.ingredientList) { $meal in
                SwipeableRow {
                    deleteIngredient(meal)
                } content: {
                    FoodItemView(foodItem: $meal)
                }
            }
        }
    }
}

private struct BuilderModeSwitcherView: View {
    @Binding var selectedMode: BuilderRecipeCreatorMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(BuilderRecipeCreatorMode.allCases, id: \.self) { item in
                Button {
                    withAnimation(.snappy) {
                        selectedMode = item
                    }
                } label: {
                    PositionalButtonView(mainText: item.title,
                                         position: item.position,
                                         isSelected: selectedMode == item,
                                         cornerRadius: 10,
                                         background: .secondaryBackground.mix(with: .primaryText, by: 0.05),
                                         mainFontWeight: .medium,
                                         mainFontWeightSelected: .bold)
                }
            }
        }
    }
}

#Preview {
    BuilderCreatorModeView(foodItem: .constant(MockData.sampleFoodItem), mealGroups: MockData.mealGroupList)
}
