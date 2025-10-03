//
//  IngredientEditorModeView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct IngredientEditorModeView: View {
    @Binding var draftFoodItem: FoodItem
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @State private var showIngredientList: Bool = false
    
    var body: some View {
        VStack {
            IngredientEditorialView(draftFoodItem: $draftFoodItem, viewModel: viewModel, showIngredientList: $showIngredientList)
        }
        .fullScreenCover(isPresented: $showIngredientList) {
            SearchFoodItemView(foodViewModel: viewModel, allowEditing: false) {
                self.showIngredientList = false
            } itemTapAction: { _, newIngredient in
                draftFoodItem.addIngredient(newIngredient)
                self.showIngredientList = false
            } isItemDisabled: { candidate in
                candidate.foodItemID == draftFoodItem.foodItemID ||
                candidate.containsIngredient(draftFoodItem) ||
                !candidate.ingredientList.filter({ $0.ingredient.foodItemID == draftFoodItem.foodItemID }).isEmpty ||
                !draftFoodItem.ingredientList.filter({ $0.ingredient.foodItemID == candidate.foodItemID }).isEmpty
            } overlayProvider: { candidate in
                if candidate.foodItemID == draftFoodItem.foodItemID {
                    return AnyView(BlockedOverlay(label: "Item Being Edited", colour: .red))
                } else if candidate.containsIngredient(draftFoodItem) {
                    return AnyView(BlockedOverlay(label: "Contains Item Currently Editing", colour: .orange))
                } else if !candidate.ingredientList.filter({ $0.ingredient.foodItemID == draftFoodItem.foodItemID }).isEmpty {
                    return AnyView(BlockedOverlay(label: "Contains Version of Item Currently Editing", colour: .orange))
                } else if !draftFoodItem.ingredientList.filter({ $0.ingredient.foodItemID == candidate.foodItemID }).isEmpty {
                    return AnyView(BlockedOverlay(label: "Already Added to Ingredients", colour: .orange))
                }
                return AnyView(EmptyView())
            }
        }
    }
}

struct IngredientEditorialView: View {
    @Binding var draftFoodItem: FoodItem
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @Binding var showIngredientList: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                IngredientListEditorialView(draftFoodItem: $draftFoodItem, viewModel: viewModel)
            }
            .clipShape(RoundedRectangle(cornerRadius: 7))
            
            Button {
                showIngredientList = true
            } label: {
                DashedButtonView(imageName: "plus")
            }
        }
    }
}

private struct IngredientListEditorialView: View {
    @Binding var draftFoodItem: FoodItem
    @ObservedObject var viewModel: NutriToolFoodViewModel
    
    private func deleteIngredient(_ ingredient: FoodItem) {
        draftFoodItem.removeIngredient(ingredient)
    }
    
    private func modifyIngredient(_ ingredient: IngredientEntry, old oldValue: Double, new newValue: Double) {
        draftFoodItem.modifyIngredient(ingredient, oldMultiplier: oldValue, newMultiplier: newValue)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach($draftFoodItem.ingredientList) { $ingredient in
                SwipeableRow {
                    deleteIngredient(ingredient.ingredient)
                } content: {
                    IngredientEntryView(
                        ingredientEntry: $ingredient,
                        latestVersionOfIngredient: viewModel.currentVersionOf(foodItemID: ingredient.ingredient.foodItemID),
                        associatedGroup: viewModel.group(for: ingredient.ingredient),
                        showGroupInfo: false
                    )
                    .onChange(of: ingredient.servingMultiplier) { oldValue, newValue in
                        modifyIngredient(ingredient, old: oldValue, new: newValue)
                    }
                }
            }
        }
    }
}

private struct BlockedOverlay: View {
    let label: String
    let colour: Color
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(colour.opacity(0.05))
            
            Text(label)
                .font(.caption2.bold())
                .padding(4)
                .background(colour.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(6)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    let viewModel = NutriToolFoodViewModel(repository: MockFoodRepository())
    IngredientEditorModeView(draftFoodItem: .constant(MockData.sampleFoodItem), viewModel: viewModel)
}
