//
//  NutrientCheckboxView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-29.
//


import SwiftUI

private struct FlatNutrient {
    let item: NutrientItem
    let level: Int
}

struct NutrientCheckboxView: View {
    let availableNutrients: [NutrientItem]
    @Binding var selectedNutrients: [NutrientItem]
    let isAtCapSelections: Bool
    
    private func binding(for nutrient: NutrientItem) -> Binding<Bool> {
        Binding(
            get: { selectedNutrients.contains(nutrient) },
            set: { isSelected in
                if isSelected {
                    if !isAtCapSelections {
                        selectedNutrients.append(nutrient)
                    }
                } else {
                    selectedNutrients.removeAll { $0.id == nutrient.id }
                }
            }
        )
    }
    
    private func flatten(nutrients: [NutrientItem], level: Int = 0) -> [FlatNutrient] {
        nutrients.flatMap { nutrient in
            [FlatNutrient(item: nutrient, level: level)] + flatten(nutrients: nutrient.childNutrients, level: level + 1)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(flatten(nutrients: availableNutrients), id: \.item.id) { flat in
                    NutrientRow(
                        nutrient: flat.item,
                        level: flat.level,
                        isOn: binding(for: flat.item),
                        activeColour: .primaryText,
                        inactiveColour: isAtCapSelections ? .secondaryText.mix(with: .primaryComplement, by: 0.6) : .primaryText
                    )
                    .disabled(!selectedNutrients.contains(flat.item) && isAtCapSelections)
                }
            }
        }
    }
}

private struct NutrientRow: View {
    let nutrient: NutrientItem
    let level: Int
    let isOn: Binding<Bool>
    let activeColour: Color
    let inactiveColour: Color
    
    var body: some View {
        let currentColour = isOn.wrappedValue ? activeColour : inactiveColour
        
        Toggle(isOn: isOn) {
            HStack {
                if level > 0 {
                    Image(systemName: "arrow.turn.down.right")
                        .padding(.leading, CGFloat(level - 1) * 20)
                }
                
                NutrientItemView(
                    nutrientOfInterest: nutrient,
                    viewType: .txt,
                    primaryTextColor: currentColour,
                    secondaryTextColor: currentColour
                )
                .font(.callout)
                .fontWeight(.light)
            }
        }
        .toggleStyle(CheckBoxStyle())
        .foregroundStyle(currentColour)
    }
}


