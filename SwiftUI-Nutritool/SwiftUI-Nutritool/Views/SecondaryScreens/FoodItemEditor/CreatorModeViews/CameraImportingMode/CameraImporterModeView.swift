//
//  CameraImporterModeView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

struct CameraImporterModeView: View {
    let successfulReturn: (FoodItem) -> Void
    @State private var intermediateResult: FoodItem?
    
    var body: some View {
        VStack {
            if intermediateResult == nil {
                NutritionScannerView(foodItem: $intermediateResult)
            }
        }
        .onChange(of: intermediateResult) { _, newValue in
            if let newValue {
                successfulReturn(newValue)
            }
        }
    }
}

#Preview {
    CameraImporterModeView() { _ in }
}
