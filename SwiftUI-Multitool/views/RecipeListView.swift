//
//  RecipeListView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

enum RecipeListViewMode {
    case normal
    case search
    case addCategory
    case addRecipe
}

// TODO: refactor and get rid of all the magic numbers used for testing
struct RecipeListView: View {
    var mealGroups: [MealGroup] = MockData.mealGroupList
    @State private var searchText: String = ""
    @State private var showAddSubMenu: Bool = false
    @State private var mode: RecipeListViewMode = .normal
    @Namespace private var plusMenuNamespace
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LazyVScroll(items: mealGroups) { mealGroup in
                MealGroupView(group: mealGroup, isExpanded: true)
            }
            
            FloatingActionButtonToolbar(isShowingSubMenu: $showAddSubMenu, recipeListScreenMode: $mode)
            
            // Popups from submenu
            if mode == .search {
                SearchPopupView(screenMode: $mode, mealGroups: mealGroups)
                    .transition(.move(edge: .bottom))
            } else if mode == .addCategory {
                AddCategoryPopupView(screenMode: $mode, mealGroups: mealGroups)
                    .transition(.move(edge: .bottom))
            } else if mode == .addRecipe {
                SearchPopupView(screenMode: $mode, mealGroups: mealGroups)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

struct PopupTextField: View {
    @Binding var textBinding: String
    var placeholder: String
    var outline: Color = .gray
    var background: Color = .white
    
    var body: some View {
        TextField(placeholder, text: $textBinding)
            .font(.headline)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .stroke(outline, lineWidth: 0.5)
                .fill(background))
    }
}

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

struct AddCategoryPopupView: View {
    @Binding var screenMode: RecipeListViewMode
    var mealGroups: [MealGroup]
    
    @State private var searchString: String = ""
    @State private var colourPicked: Color = .blue
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                MealGroupView(group: MealGroup(name: searchString, meals: [MockData.sampleFoodItem], colour: colourPicked.toHex()!))
                    .id(searchString + (colourPicked.toHex() ?? ""))
                    .padding(.vertical)
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Text("Preview")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .opacity(0.2))
                            .padding(4)
                    }
                }
                .phaseAnimator([1.0, 0]) { content, phase in
                    content.opacity(phase)
                } animation: { _ in
                        .easeInOut(duration: 5.0)
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .randomNoiseShader()
                    .opacity(0.1)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(.clear, lineWidth: 1))
                
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .frame(maxHeight: 500)
            
            Spacer()
            
            PopupTextField(textBinding: $searchString, placeholder: "Group name... eg: Breakfast", outline: colourPicked)
            
            ColorPicker("Colour of the Group Header", selection: $colourPicked)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Spacer()
            
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

// "FAB" Menu
struct FloatingActionButtonToolbar: View {
    @Binding var isShowingSubMenu: Bool
    @Binding var recipeListScreenMode: RecipeListViewMode
    
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
                .foregroundStyle(.black)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .scaleEffect(isShowingSubMenu ? 1 : 0.05, anchor: .bottomTrailing)
                .opacity(isShowingSubMenu ? 1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowingSubMenu)
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowingSubMenu.toggle()
                }
            } label: {
                Image(systemName: "plus")
                    .rotationEffect(.degrees(isShowingSubMenu ? 45 : 0))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(16)
                    .background(
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.8),
                                            .blue.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // glass-like blur (SwiftUI normal blur no bueno)
                            Circle()
                                .fill(.white.opacity(0.1))
                                .background(.thinMaterial,
                                            in: Circle()
                                )
                        }
                    )
                    .overlay(
                        Circle()
                            .stroke(.blue.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .scaleEffect(isShowingSubMenu ? 0.8 : 1.0)
            }
            .padding(.trailing, isShowingSubMenu ? 10 : 20)
            .padding(.bottom, isShowingSubMenu ? 10 : 20)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowingSubMenu)
            .zIndex(2)
        }
    }
}

struct ReLiSubMenu: View {
    @Binding var screenMode: RecipeListViewMode
    @Binding var showingCustomMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SubMenuButton(title: "Search Recipe", icon: "magnifyingglass") {
                screenMode = .search
                showingCustomMenu = false
            }
            SubMenuButton(title: "Add Category", icon: "folder.badge.plus") {
                screenMode = .addCategory
                showingCustomMenu = false
            }
            SubMenuButton(title: "Add Recipe", icon: "plus.circle") {
                screenMode = .addRecipe
                showingCustomMenu = false
            }
        }
        .padding(14)
        .background(
            // Glassy background with blur + gradient
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
}

struct SubMenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.2))
                    )
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white.opacity(0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect(.highlight)
    }
}

#Preview {
    RecipeListView()
}
