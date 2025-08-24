//
//  BuilderCreatorModeView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct BuilderCreatorModeView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        VStack {
            Text("Builder Mode")
        }
    }
}

#Preview {
    BuilderCreatorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
