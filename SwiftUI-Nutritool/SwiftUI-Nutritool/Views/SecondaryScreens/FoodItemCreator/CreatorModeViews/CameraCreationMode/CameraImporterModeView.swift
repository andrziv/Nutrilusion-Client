//
//  CameraImporterModeView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct CameraImporterModeView: View {
    @Binding var foodItem: FoodItem
    @State private var intermediateResult: FoodItem?
    
    init(foodItem: Binding<FoodItem>) {
        self._foodItem = foodItem
        self.intermediateResult = foodItem.wrappedValue
    }
    
    var body: some View {
        VStack {
            if intermediateResult != nil {
                NutrientEditorModeView(foodItem: $foodItem)
            } else {
                NutritionLiveScannerView(foodItem: $intermediateResult)
            }
        }
        .onChange(of: intermediateResult) { _, newValue in
            if let newValue = newValue {
                foodItem = newValue 
            }
        }
    }
}

#Preview {
    CameraImporterModeView(foodItem: .constant(MockData.sampleFoodItem))
}
