//
//  NutrientTreeEditorialView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-23.
//


import SwiftUI

struct NutrientTreeEditorialView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        ScrollView {
            ForEach($foodItem.nutritionList, id: \.id) { $nutrientItem in
                EditorialNutrientBlockEntry(nutrient: $nutrientItem)
                    .fontWeight(.semibold)
                
                EditorialNutrientRecursionView(nutrient: $nutrientItem)
            }
        }
        .font(.footnote)
        .labelStyle(CustomLabel(spacing: 7))
    }
}

struct EditorialNutrientRecursionView: View {
    @Binding var nutrient: NutrientItem
    private(set) var isOrigin: Bool = true
    
    var body: some View {
        ForEach($nutrient.childNutrients) { $childNutrient in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    EditorialNutrientBlockEntry(nutrient: $childNutrient)
                        .fontWeight(.light)
                }
                EditorialNutrientRecursionView(nutrient: $childNutrient, isOrigin: false)
            }
            .padding(.leading, isOrigin ? 0 : 25)
        }
    }
}

private struct EditorialNutrientBlockEntry: View {
    @Binding var nutrient: NutrientItem
    
    var body: some View {
        EditorialBlockEntry(title: nutrient.name, value: $nutrient.amount, unit: nutrient.unit)
    }
}

#Preview {
    NutrientTreeEditorialView(foodItem: .constant(MockData.sampleFoodItem))
}
