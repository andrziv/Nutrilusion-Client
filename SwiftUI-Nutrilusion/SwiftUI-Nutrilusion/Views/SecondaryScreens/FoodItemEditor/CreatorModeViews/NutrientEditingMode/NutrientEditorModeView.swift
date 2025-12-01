//
//  NutrientEditorModeView.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct NutrientEditorModeView: View {
    @Binding var foodItem: FoodItem
    @State private var showNutritionList: Bool = false
    @State private var isValuePropagationActive: Bool = false
    
    var body: some View {
        VStack {
            let toggleColourAccent = isValuePropagationActive ? Color.green : Color.red
            let toggleColour = Color.primaryComplement.mix(with: toggleColourAccent, by: 0.5)
            
            VStack {
                EditorialCalorieBlockEntry(foodItem: $foodItem)
                    .font(.callout)
                    .fontWeight(.heavy)
                
                NutrientTreeEditorialView(foodItem: $foodItem, propagateChanges: isValuePropagationActive)
            }
            .padding(.horizontal, 8)
            
            HStack(spacing: 12){
                Toggle(isOn: $isValuePropagationActive) {
                    Text("Propagate")
                        .lineLimit(1)
                        .font(.callout)
                }
                .toggleStyle(CheckBoxStyle())
                .foregroundStyle(.primaryText)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 7).fill(toggleColour))
                
                Button {
                    showNutritionList = true
                } label: {
                    DashedButtonView(imageName: "plus", cornerRadius: 7)
                }
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
    NutrientEditorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
