//
//  ManualCreatorModeView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct ManualCreatorModeView: View {
    @Binding var foodItem: FoodItem
    @State private var showNutritionList: Bool = false
    
    var body: some View {
        VStack {
            EditorialCalorieBlockEntry(foodItem: $foodItem)
                .font(.callout)
                .fontWeight(.heavy)
            
            NutrientTreeEditorialView(foodItem: $foodItem)

            Button {
                showNutritionList = true
            } label: {
                DashedButtonView(imageName: "plus")
            }
        }
        .fullScreenCover(isPresented: $showNutritionList) {
            NutrientAdderPopup(isActive: $showNutritionList, foodItem: $foodItem)
        }
    }
}



private struct EditorialCalorieBlockEntry: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        EditorialCalorieEntry(title: "Calories", value: $foodItem.calories, unit: "kcal")
    }
}

#Preview {
    ManualCreatorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
