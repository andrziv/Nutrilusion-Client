//
//  NutrientTreeEditorialView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-23.
//

import SwiftUI


struct NutrientTreeEditorialView: View {
    @Binding var foodItem: FoodItem
    let propagateChanges: Bool
    
    var body: some View {
        ScrollView {
            ForEach($foodItem.nutritionList) { $nutrientItem in
                EditorialNutrientBlockEntry(nutrient: $nutrientItem, foodItem: $foodItem, propagateChanges: propagateChanges)
                    .fontWeight(.semibold)
                
                EditorialNutrientRecursionView(nutrient: $nutrientItem, foodItem: $foodItem, propagateChanges: propagateChanges)
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
    let propagateChanges: Bool
    private(set) var depth: Int = 0
    
    @State private var isHighlighted: Bool = false
    
    func isOrigin() -> Bool {
        depth == 0
    }
    
    var body: some View {
        ForEach($nutrient.childNutrients) { $childNutrient in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .foregroundColor(isHighlighted ? .green : .secondary)
                        .scaleEffect(isHighlighted ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
                    
                    EditorialNutrientBlockEntry(nutrient: $childNutrient, foodItem: $foodItem, propagateChanges: propagateChanges)
                        .fontWeight(.light)
                }
                EditorialNutrientRecursionView(nutrient: $childNutrient, foodItem: $foodItem, propagateChanges: propagateChanges, depth: depth + 1)
            }
            .padding(.leading, isOrigin() ? 0 : 25)
            .onChange(of: propagateChanges) { _, newValue in
                guard newValue else { return }
                
                // TODO: idk if this animation is enough to convey what's really happening when "Propagate" is active
                //  maybe worth taking a looking at TipKit to show some info the first time it's activated
                let delay = depth * 150
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHighlighted = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            isHighlighted = false
                        }
                    }
                }
            }
        }
    }
}

private struct EditorialNutrientBlockEntry: View {
    @Binding var nutrient: NutrientItem
    @Binding var foodItem: FoodItem
    let propagateChanges: Bool
    
    @FocusState private var isFocused: Bool
    @State private var draftAmount: Double
    
    init(nutrient: Binding<NutrientItem>, foodItem: Binding<FoodItem>, propagateChanges: Bool) {
        self._nutrient = nutrient
        self._foodItem = foodItem
        self.draftAmount = nutrient.wrappedValue.amount
        self.propagateChanges = propagateChanges
    }
    
    private func commit() {
        if draftAmount != nutrient.amount {
            foodItem.modifyNutrient(nutrient.name, newValue: draftAmount, propagateChanges: propagateChanges)
        }
    }
    
    var body: some View {
        SwipeableRow {
            foodItem.deleteNutrient(nutrient.name)
        } content: {
            EditorialNutrientEntry(title: nutrient.name, value: $draftAmount, unit: nutrient.unit) { newUnit in
                if newUnit != nutrient.unit {
                    foodItem.modifyNutrient(nutrient.name, newUnit: newUnit, propagateChanges: propagateChanges)
                }
            }
            .focused($isFocused)
            .onSubmit { commit() }
            .onChange(of: isFocused) { _, focused in
                if !focused { commit() }
            }
            .onChange(of: nutrient) { old, newValue in
                if newValue.amount != draftAmount || old.unit != newValue.unit {
                    draftAmount = newValue.amount
                }
            }
        }
    }
}

#Preview {
    NutrientTreeEditorialView(foodItem: .constant(MockData.sampleFoodItem), propagateChanges: false)
}
