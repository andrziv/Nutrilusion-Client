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
    
    var title: String {
        switch self {
        case .search: return ""
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

// TODO: temp to make the adding work. Eventually replace with real ViewModel + Persistance
class MealGroupsModel: ObservableObject {
    @Published var mealGroups: [MealGroup] = MockData.mealGroupList
}

// TODO: refactor and get rid of all the magic numbers used for testing
struct RecipeListView: View {
    @StateObject var model = MealGroupsModel()
    @State private var mode: RecipeListViewMode? = nil
    
    let foodTapAction: (FoodItem) -> Void
    
    private func appendNewItem(_ newItem: FoodItem, selectedMealGroup: MealGroup) {
        if let index = model.mealGroups.firstIndex(where: { $0.id == selectedMealGroup.id }) {
            var group = model.mealGroups[index]
            group.meals.append(newItem)
            model.mealGroups[index] = group
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LazyVScroll(items: model.mealGroups, spacing: 0) { mealGroup in
                MealGroupView(group: mealGroup, isExpanded: true) { foodItem in
                    foodTapAction(foodItem)
                }
                .padding(.top)
                .padding(.bottom, model.mealGroups.last == mealGroup ? 65 : 0)
            }
            
            FloatingActionMenu(mode: $mode)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .fullScreenCover(item: $mode) { mode in
            switch mode {
            case .search:
                SearchPopupView(mealGroups: model.mealGroups) {
                    self.mode = nil
                } itemTapAction: { foodItem in
                    foodTapAction(foodItem)
                    self.mode = nil
                }
                .transition(.move(edge: .bottom))
                
            case .addCategory:
                AddCategoryPopupView(screenMode: $mode, mealGroups: $model.mealGroups)
                    .transition(.move(edge: .bottom))
                
            case .addRecipe:
                RecipeCreatorView(foodItem: FoodItem(name: ""), mealGroups: model.mealGroups) {
                    self.mode = nil
                } onSaveAction: { selectedGroup, editedFoodItem in
                    appendNewItem(editedFoodItem, selectedMealGroup: selectedGroup)
                    self.mode = nil
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

private struct FloatingActionMenu: View {
    @Binding var mode: RecipeListViewMode?
    
    var body: some View {
        HStack {
            HStack(spacing: 24) {
                VerticalActionButton(title: RecipeListViewMode.addCategory.title, icon: RecipeListViewMode.addCategory.icon) {
                    mode = .addCategory
                }
                VerticalActionButton(title: RecipeListViewMode.addRecipe.title, icon: RecipeListViewMode.addRecipe.icon) {
                    mode = .addRecipe
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 7.5)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            
            VerticalActionButton(title: RecipeListViewMode.search.title, icon: RecipeListViewMode.search.icon) {
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

// TODO: refactor ImagedButton to either be horizontal or vertical and use that instead?
struct VerticalActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                if !title.isEmpty {
                    Text(title)
                        .font(.caption2)
                }
            }
            .foregroundStyle(.primaryText)
            .foregroundStyle(.primary)
            .frame(minWidth: 56)
        }
    }
}


#Preview {
    RecipeListView() { foodItem in
        
    }
}
