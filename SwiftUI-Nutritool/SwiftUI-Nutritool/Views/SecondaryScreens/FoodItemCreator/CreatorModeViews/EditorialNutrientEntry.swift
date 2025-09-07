//
//  EditorialBlockEntry.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-25.
//


import SwiftUI

struct EditorialNutrientEntry: View {
    let title: String
    @Binding var value: Double
    var unit: NutrientUnit
    let unitMenuAction: (NutrientUnit) -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            HStack(spacing: 6) {
                BasicTextField("##", value: $value, format: .number,
                               background: .secondaryBackground,
                               horizontalPadding: 8,
                               verticalPadding: 6)
                    .multilineTextAlignment(.center)
                    .frame(width: 64)
                
                NutrientUnitPicker(selectedUnit: unit, action: unitMenuAction)
                    .foregroundStyle(.primaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.secondaryBackground)
        )
    }
}

struct NutrientUnitPicker: View {
    var selectedUnit: NutrientUnit
    let action: (NutrientUnit) -> Void
    
    var body: some View {
        Menu {
            ForEach(NutrientUnit.allCases) { unit in
                Button() {
                    action(unit)
                } label: {
                    Text("\(unit)")
                    if unit == selectedUnit {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text("\(selectedUnit)")
                    .font(.caption.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(width: 55)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondaryText.mix(with: .backgroundColour, by: 0.4).opacity(0.15))
            )
        }
    }
}

struct EditorialCalorieEntry: View {
    let title: String
    @Binding var value: Int
    let unit: String
    
    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            HStack(spacing: 6) {
                BasicTextField("##", value: $value, format: .number,
                               background: .secondaryBackground,
                               horizontalPadding: 8,
                               verticalPadding: 6)
                    .multilineTextAlignment(.center)
                    .frame(width: 75)
                
                Text(unit)
                    .foregroundStyle(.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(width: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.secondaryText.mix(with: .backgroundColour, by: 0.74).opacity(0.15))
                    )
            }
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.secondaryBackground)
        )
    }
}
