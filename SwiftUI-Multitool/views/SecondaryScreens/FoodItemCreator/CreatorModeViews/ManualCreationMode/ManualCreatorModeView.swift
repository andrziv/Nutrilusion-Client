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
            CalorieStatView(foodItem: foodItem,
                            viewType: .txt,
                            primaryTextColor: .primaryText)
            .labelStyle(CustomLabel(spacing: 7))
            .font(.callout)
            .fontWeight(.bold)
            
            ForEach(foodItem.nutritionList, id: \.id) { nutrientItem in
                NutrientItemView(nutrientOfInterest: nutrientItem,
                                 viewType: .txt,
                                 primaryTextColor: .primaryText)
                .fontWeight(.semibold)
                
                ChildNutrientRecursionView(nutrient: nutrientItem)
            }
            .font(.footnote)
            .labelStyle(CustomLabel(spacing: 7))
            
            Button {
                showNutritionList = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.backgroundColour.mix(with: .primaryText, by: 0.1)))
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8, 10]))
                            .foregroundStyle(.primaryText.mix(with: .backgroundColour, by: 0.5))
                    }
            }
        }
        .fullScreenCover(isPresented: $showNutritionList) {
            NutrientAdderPopup(isActive: $showNutritionList, foodItem: $foodItem)
        }
    }
}

#Preview {
    ManualCreatorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
