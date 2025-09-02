//
//  BuilderCreatorModeView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-24.
//


import SwiftUI

fileprivate enum BuilderRecipeCreatorMode: Int, CaseIterable {
    case ingredients = 0
    case details
    
    var title: String {
        switch self {
        case .ingredients:
            return "Ingredient Details"
        case .details:
            return "Nutrient Details"
        }
    }
    
    var position: Position {
        switch self {
        case .ingredients:
            return Position.left
        case .details:
            return Position.right
        }
    }
}

struct BuilderCreatorModeView: View {
    @Binding var foodItem: FoodItem
    @State private var selectedMode: BuilderRecipeCreatorMode = .ingredients
    
    var body: some View {
        VStack {
            BuilderModeSwitcherView(selectedMode: $selectedMode)
            
            if selectedMode == .ingredients {
                Text("Ingredient Details")
            } else if selectedMode == .details {
                ManualCreatorModeView(foodItem: $foodItem)
            }
        }
    }
}

private struct BuilderModeSwitcherView: View {
    @Binding var selectedMode: BuilderRecipeCreatorMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(BuilderRecipeCreatorMode.allCases, id: \.self) { item in
                Button {
                    withAnimation(.snappy) {
                        selectedMode = item
                    }
                } label: {
                    PositionalButtonView(mainText: item.title,
                                         position: item.position,
                                         isSelected: selectedMode == item,
                                         cornerRadius: 10,
                                         background: .secondaryBackground.mix(with: .primaryText, by: 0.05),
                                         mainFontWeight: .medium,
                                         mainFontWeightSelected: .bold)
                }
            }
        }
    }
}

#Preview {
    BuilderCreatorModeView(foodItem: .constant(MockData.sampleFoodItem))
}
