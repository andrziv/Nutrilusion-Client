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
    @Binding var draftFoodItem: FoodItem
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @State private var selectedMode: BuilderRecipeCreatorMode = .ingredients
    @State private var showIngredientList: Bool = false
    
    var body: some View {
        VStack {
            BuilderModeSwitcherView(selectedMode: $selectedMode)
            
            if selectedMode == .ingredients {
                IngredientEditorialView(draftFoodItem: $draftFoodItem, viewModel: viewModel, showIngredientList: $showIngredientList)
            } else if selectedMode == .details {
                ManualCreatorModeView(foodItem: $draftFoodItem)
            }
        }
        .fullScreenCover(isPresented: $showIngredientList) {
            SearchPopupView(foodViewModel: viewModel, allowEditing: false) {
                self.showIngredientList = false
            } itemTapAction: { _, newIngredient in
                draftFoodItem.addIngredient(newIngredient)
                self.showIngredientList = false
            } isItemDisabled: { candidate in
                candidate.id == draftFoodItem.id || candidate.containsIngredient(draftFoodItem)
            } overlayProvider: { candidate in
                if candidate.id == draftFoodItem.id {
                    return AnyView(BlockedOverlay(label: "Item Being Edited", colour: .red))
                } else if candidate.containsIngredient(draftFoodItem) {
                    return AnyView(BlockedOverlay(label: "Contains Current Item", colour: .orange))
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
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(draftFoodItem.ingredientList) { ingredient in
                SwipeableRow {
                    deleteIngredient(ingredient)
                } content: {
                    FoodItemView(
                        foodItemID: ingredient.id,
                        viewModel: viewModel,
                        showGroupInfo: false,
                        editingAllowed: false
                    )
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
    BuilderCreatorModeView(draftFoodItem: .constant(MockData.sampleFoodItem), viewModel: viewModel)
}
