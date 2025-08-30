//
//  RecipeListView.swift
//  SwiftUI-Multitool
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
}

// TODO: refactor and get rid of all the magic numbers used for testing
struct RecipeListView: View {
    @State var mealGroups: [MealGroup] = MockData.mealGroupList
    @State private var showAddSubMenu: Bool = false
    @State private var mode: RecipeListViewMode? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LazyVScroll(items: mealGroups, spacing: 0) { mealGroup in
                MealGroupView(group: mealGroup, isExpanded: true)
                    .padding(.top)
            }
            
            FloatingActionButtonToolbar(isShowingSubMenu: $showAddSubMenu, recipeListScreenMode: $mode)
        }
        .fullScreenCover(item: $mode) { mode in
            // Popups from submenu
            if mode == .search {
                SearchPopupView(screenMode: $mode, mealGroups: mealGroups)
                    .transition(.move(edge: .bottom))
            } else if mode == .addCategory {
                AddCategoryPopupView(screenMode: $mode, mealGroups: $mealGroups)
                    .transition(.move(edge: .bottom))
            } else if mode == .addRecipe {
                RecipeCreatorView(foodItem: FoodItem(name: ""), onExitAction: {
                    self.mode = nil
                })
                .transition(.move(edge: .bottom))
            }
        }
        .background(.ultraThinMaterial)
    }
}

// "FAB" Menu
struct FloatingActionButtonToolbar: View {
    @Binding var isShowingSubMenu: Bool
    @Binding var recipeListScreenMode: RecipeListViewMode?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // kludge to close the menu when user taps outside of the menu
            if isShowingSubMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isShowingSubMenu = false
                        }
                    }
            }
            
            // Submenu expanding from FAB
            ReLiSubMenu(screenMode: $recipeListScreenMode, showingCustomMenu: $isShowingSubMenu)
                .foregroundStyle(.primaryText)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .scaleEffect(isShowingSubMenu ? 1 : 0.05, anchor: .bottomTrailing)
                .opacity(isShowingSubMenu ? 1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowingSubMenu)
            
            ReLiButton(isShowingSubMenu: $isShowingSubMenu)
                .padding(.trailing, isShowingSubMenu ? 10 : 20)
                .padding(.bottom, isShowingSubMenu ? 10 : 20)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowingSubMenu)
                .zIndex(2)
        }
    }
}

struct ReLiSubMenu: View {
    @Binding var screenMode: RecipeListViewMode?
    @Binding var showingCustomMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ImagedButton(title: "Search Recipe", icon: "magnifyingglass") {
                screenMode = .search
                showingCustomMenu = false
            }
            ImagedButton(title: "Add Category", icon: "folder.badge.plus") {
                screenMode = .addCategory
                showingCustomMenu = false
            }
            ImagedButton(title: "Add Recipe", icon: "plus.circle") {
                screenMode = .addRecipe
                showingCustomMenu = false
            }
        }
        .padding(14)
        .background(
            // Glassy background with blur + gradient
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .primaryText.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
}

struct ReLiButton: View {
    @Binding var isShowingSubMenu: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isShowingSubMenu.toggle()
            }
        } label: {
            Image(systemName: "plus")
                .rotationEffect(.degrees(isShowingSubMenu ? 45 : 0))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primaryText)
                .padding(16)
                .background(
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .backgroundColour.opacity(0.8),
                                        .blue.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // glass-like blur (SwiftUI normal blur no bueno)
                        Circle()
                            .fill(.backgroundColour.opacity(0.1))
                            .background(.thinMaterial,
                                        in: Circle()
                            )
                    }
                )
                .overlay(
                    Circle()
                        .stroke(.blue.opacity(0.4), lineWidth: 0.5)
                )
                .shadow(color: .primaryText.opacity(0.03), radius: 10, x: 0, y: 5)
                .scaleEffect(isShowingSubMenu ? 0.8 : 1.0)
        }
    }
}

#Preview {
    RecipeListView()
}
