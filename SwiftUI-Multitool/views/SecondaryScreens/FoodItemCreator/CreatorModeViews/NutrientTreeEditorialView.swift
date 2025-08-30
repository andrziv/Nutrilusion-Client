//
//  NutrientTreeEditorialView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-23.
//
// TODO: come back to this later and see if you can do it in a better way

import SwiftUI


struct NutrientTreeEditorialView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        ScrollView {
            ForEach($foodItem.nutritionList) { $nutrientItem in
                EditorialNutrientBlockEntry(nutrient: $nutrientItem, foodItem: $foodItem)
                    .fontWeight(.semibold)
                
                EditorialNutrientRecursionView(nutrient: $nutrientItem, foodItem: $foodItem)
            }
            .padding(.top, 0.5) // just to make it so that the value textfield outline isn't clipping the top
        }
        .font(.footnote)
        .labelStyle(CustomLabel(spacing: 7))
    }
}

struct EditorialNutrientRecursionView: View {
    @Binding var nutrient: NutrientItem
    @Binding var foodItem: FoodItem
    private(set) var isOrigin: Bool = true
    
    var body: some View {
        ForEach($nutrient.childNutrients) { $childNutrient in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    EditorialNutrientBlockEntry(nutrient: $childNutrient, foodItem: $foodItem)
                        .fontWeight(.light)
                }
                EditorialNutrientRecursionView(nutrient: $childNutrient, foodItem: $foodItem, isOrigin: false)
            }
            .padding(.leading, isOrigin ? 0 : 25)
        }
    }
}

private struct EditorialNutrientBlockEntry: View {
    @Binding var nutrient: NutrientItem
    @Binding var foodItem: FoodItem
    
    @FocusState private var isFocused: Bool
    @State private var draftAmount: Double
    
    init(nutrient: Binding<NutrientItem>, foodItem: Binding<FoodItem>) {
        self._nutrient = nutrient
        self._foodItem = foodItem
        self._draftAmount = State(initialValue: nutrient.wrappedValue.amount)
    }
    
    private func commit() {
        if draftAmount != nutrient.amount {
            foodItem.modifyNutrient(nutrient.name, newValue: draftAmount)
        }
    }
    
    var body: some View {
        SwipeableRow {
            foodItem.deleteNutrient(nutrient.name)
        } content: {
            EditorialNutrientEntry(title: nutrient.name, value: $draftAmount, unit: nutrient.unit) { newUnit in
                if newUnit != nutrient.unit {
                    foodItem.modifyNutrient(nutrient.name, newUnit: newUnit)
                }
            }
            .focused($isFocused)
            .onSubmit { commit() }
            .onChange(of: isFocused) { _, focused in
                if !focused { commit() }
            }
            .onChange(of: nutrient.amount) { old, newValue in
                if newValue != draftAmount {
                    draftAmount = newValue
                }
            }
        }
    }
}

#Preview {
    NutrientTreeEditorialView(foodItem: .constant(MockData.sampleFoodItem))
}
