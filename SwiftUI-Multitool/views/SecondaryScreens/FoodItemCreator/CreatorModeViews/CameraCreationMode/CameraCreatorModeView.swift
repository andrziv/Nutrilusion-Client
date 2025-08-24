//
//  CameraCreatorModeView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct CameraCreatorModeView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        VStack {
            Text("Camera Mode")
        }
    }
}

#Preview {
    CameraCreatorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
