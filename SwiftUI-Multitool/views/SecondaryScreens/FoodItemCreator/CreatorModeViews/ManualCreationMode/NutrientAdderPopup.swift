//
//  NutrientAdderPopup.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-16.
//

import SwiftUI

struct NutrientAdderPopup: View {
    @Binding var isActive: Bool
    @Binding var foodItem: FoodItem
    
    var body: some View {
        VStack {
            NutrientTreeButtonView(foodItem: $foodItem, isShowing: $isActive)
            
            ImagedButton(title: "Dismiss", icon: "xmark", circleColour: .clear, cornerRadius: 10) {
                isActive = false
            }
            .frame(maxWidth: .infinity)
        }
        .basicBackground()
    }
}

#Preview {
    NutrientAdderPopup(isActive: .constant(true), foodItem: .constant(MockData.sampleFoodItem))
}
