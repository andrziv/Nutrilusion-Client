//
//  ManualCreatorModeView.swift
//  SwiftUI-Multitool
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
                ShowNutrientsButtonView()
            }
        }
        .fullScreenCover(isPresented: $showNutritionList) {
            NutrientAdderPopup(isActive: $showNutritionList, foodItem: $foodItem)
        }
    }
}

struct ShowNutrientsButtonView: View {
    var body: some View {
        Image(systemName: "plus")
            .foregroundStyle(.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 20).fill(.secondaryText.mix(with: .backgroundColour, by: 0.65)))
            .overlay{
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundStyle(.primaryText.mix(with: .backgroundColour, by: 0.5))
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
