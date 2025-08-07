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
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(mealGroups) { mealGroup in
                        MealGroupView(group: mealGroup, isExpanded: true)
                    }
                }
            }
            
            FloatingActionButtonToolbar(isShowingSubMenu: $showAddSubMenu, recipeListScreenMode: $mode)
            
            // Popups from submenu
            if mode == .search {
                SearchPopupView(screenMode: $mode)
                    .transition(.move(edge: .bottom))
            } else if mode == .addCategory {
                SearchPopupView(screenMode: $mode)
                    .transition(.move(edge: .bottom))
            } else if mode == .addRecipe {
                SearchPopupView(screenMode: $mode)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

struct SearchPopupView: View {
    @Binding var screenMode: RecipeListViewMode
    @State var searchString: String = ""
    
    struct VisualEffectView: UIViewRepresentable {
        var effect: UIVisualEffect?
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
        func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
    }
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .light))
                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                TextField("Search for Recipe Names... eg: Greek Yogurt", text: $searchString)
                    .font(.headline)
                Button("Dismiss") {
                    withAnimation {
                        screenMode = .normal
                    }
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
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
                                .background(.ultraThinMaterial,
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
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.9),
                            .blue.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    Color(.systemBackground)
                        .opacity(0.8)
                        .blur(radius: 10)
                )
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
