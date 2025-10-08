//
//  NutrientChipView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-29.
//

import SwiftUI

struct NutrientChipView: View {
    @Binding var selectedNutrients: [NutrientItem]
    
    var body: some View {
        ChipGrid(data: selectedNutrients, spacing: 6, alignment: .leading) { nutrient in
            Button {
                if let index = selectedNutrients.firstIndex(of: nutrient) {
                    selectedNutrients.remove(at: index)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                    Text("\(nutrient.name) \(RoundingDouble(nutrient.amount))\(nutrient.unit.description)")
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundStyle(.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondaryText.mix(with: .primaryComplement, by: 0.85))
                )
            }
        }
    }
}
