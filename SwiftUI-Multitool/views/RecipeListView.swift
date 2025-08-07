//
//  RecipeListView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

struct RecipeListView: View {
    var mealGroups: [MealGroup] = MockData.mealGroupList
    @State private var searchText: String = ""
    @State private var showAddSubmMenu: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(mealGroups) { mealGroup in
                        MealGroupView(group: mealGroup, isExpanded: true)
                    }
                }
            }
            
            if showAddSubmMenu {
                Button {
                    withAnimation {
                        showAddSubmMenu = false
                    }
                } label: {
                    AddSubMenuView()
                        .font(.headline)
                        .fontWeight(.medium)
                        .offset(x: -20)
                        .foregroundColor(.black)
                }
            } else {
                Button {
                    withAnimation {
                        showAddSubmMenu = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .padding(20)
                        .foregroundColor(.black)
                        .background(Color(red: 0.8, green: 0.8, blue: 1),
                                    in: Circle())
                        .offset(x: -20)
                }
            }
        }
    }
}

struct AddSubMenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SubMenuItemView(title: "Search Recipe", imageName: "magnifyingglass")
            SubMenuItemView(title: "Add Category", imageName: "plus")
            SubMenuItemView(title: "Add Recipe", imageName: "plus")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.8, green: 0.8, blue: 1))
        )
    }
}

struct SubMenuItemView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        Label(title, systemImage: imageName)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.7, green: 0.7, blue: 1))
            )
    }
}

#Preview {
    RecipeListView()
}
