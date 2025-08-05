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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(mealGroups) { mealGroup in
                    MealGroupView(group: mealGroup, isExpanded: true)
                }
            }
        }
    }
}

#Preview {
    RecipeListView()
}
