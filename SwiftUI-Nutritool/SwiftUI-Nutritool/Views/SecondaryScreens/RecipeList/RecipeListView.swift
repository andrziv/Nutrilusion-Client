//
//  RecipeListView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

enum RecipeListViewMode: Identifiable {
    case search
    case addCategory
    case addRecipe
    
    var id: Int {
        switch self {
        case .search: return 1
        case .addCategory: return 2
        case .addRecipe: return 3
        }
    }
    
    var title: String? {
        switch self {
        case .search: return nil
        case .addCategory: return "Category"
        case .addRecipe: return "Recipe"
        }
    }
    
    var icon: String {
        switch self {
        case .search: return "magnifyingglass"
        case .addCategory: return "folder.badge.plus"
        case .addRecipe: return "plus.circle"
        }
    }
}

// TODO: refactor and get rid of all the magic numbers used for testing
struct RecipeListView: View {
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @State private var mode: RecipeListViewMode? = nil
    
    let foodTapAction: (MealGroup, FoodItem) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LazyVScroll(items: viewModel.mealGroups, spacing: 12) { mealGroup in
                MealGroupView(viewModel: viewModel,
                              group: mealGroup,
                              editingAllowed: true,
                              isExpanded: true) { foodItem in
                    foodTapAction(mealGroup, foodItem)
                }
                .padding(.bottom, viewModel.mealGroups.last == mealGroup ? 65 : 0)
            }
            
            FloatingActionMenu(mode: $mode)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .basicBackground(shadowRadius: 0, background: .backgroundColour)
        .ignoresSafeArea(.all, edges: .bottom)
        .fullScreenCover(item: $mode) { mode in
            switch mode {
            case .search:
                SearchFoodItemView(foodViewModel: viewModel, allowEditing: true) {
                    self.mode = nil
                } itemTapAction: { mealGroup, foodItem in
                    foodTapAction(mealGroup, foodItem)
                    self.mode = nil
                }
                
            case .addCategory:
                AddCategoryPopupView(viewModel: viewModel, screenMode: $mode) { newMealGroup in
                    viewModel.addGroup(newMealGroup)
                }
                
            case .addRecipe:
                RecipeEditorView(foodItem: FoodItem(name: ""), viewModel: viewModel) {
                    self.mode = nil
                } onSaveAction: { selectedGroup, editedFoodItem in
                    if let selectedGroup = selectedGroup {
                        viewModel.addFood(editedFoodItem, to: selectedGroup)
                    }
                    self.mode = nil
                }
            }
        }
    }
}

private struct FloatingActionMenu: View {
    @Binding var mode: RecipeListViewMode?
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 24) {
                FloatingMenuButton(title: RecipeListViewMode.addCategory.title, icon: RecipeListViewMode.addCategory.icon) {
                    mode = .addCategory
                }
                FloatingMenuButton(title: RecipeListViewMode.addRecipe.title, icon: RecipeListViewMode.addRecipe.icon) {
                    mode = .addRecipe
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 7.5)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            
            FloatingMenuButton(title: RecipeListViewMode.search.title, icon: RecipeListViewMode.search.icon) {
                mode = .search
            }
            .padding(15)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

private struct FloatingMenuButton: View {
    let title: String?
    let icon: String
    let action: () -> Void
    
    var body: some View {
        ImagedButton(title: title,
                     icon: icon,
                     textFont: .caption2,
                     circleColour: .clear,
                     verticalPadding: 0,
                     horizontalPadding: 0,
                     backgroundColour: .clear,
                     iconPlacement: .top,
                     action: action)
    }
}


#Preview {
    RecipeListView(viewModel: NutriToolFoodViewModel(repository: MockFoodRepository())) { mealGroup, foodItem in
        
    }
}
