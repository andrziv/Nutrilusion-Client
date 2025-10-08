//
//  NutrientItemView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

enum StatViewType {
    case img
    case txt
}

struct NutrientItemView: View {
    let nutrientOfInterest: NutrientItem
    var multiplier: Double = 1
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            let amountInGrams = nutrientOfInterest.unit.convertTo(multiplier * nutrientOfInterest.amount, to: .grams)
            let bestUnit = NutrientUnit.bestUnit(for: amountInGrams)
            let amount = NutrientUnit.grams.convertTo(amountInGrams, to: bestUnit)
            NutrientItemImageView(nutrientName: nutrientOfInterest.name, amount: amount, unit: bestUnit)
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("\(nutrientOfInterest.name)")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(nutrientOfInterest.amount * multiplier)) \(nutrientOfInterest.unit.description)")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct NutrientItemImageView: View {
    let nutrientName: String
    let amount: Double
    let unit: NutrientUnit
    
    var body: some View {
        Label {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(RoundingDouble(amount))
                if !unit.shortDescription.isEmpty{
                    Text(unit.shortDescription)
                        .font(.system(size: 10, weight: .semibold))
                        .italic()
                }
            }
        } icon: {
            Image(systemName: NutrientSymbolMapper.shared.symbol(for: nutrientName))
        }
    }
}

struct CalorieStatView: View {
    let foodItem: FoodItem
    var multiplier: Double = 1
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(Double(foodItem.calories) * multiplier), systemImage: NutrientSymbolMapper.shared.symbol(for: "Calories"))
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Calories")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(Double(foodItem.calories) * multiplier)) kcal")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct ServingSizeView: View {
    let foodItem: FoodItem
    var multiplier: Double = 1
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(ServingSizeText(foodItem, multiplier: multiplier), systemImage: "dot.square")
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Serving Size")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text(ServingSizeText(foodItem, multiplier: multiplier))
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

func ServingSizeText(_ foodItem: FoodItem, multiplier: Double = 1) -> String {
    let servingTotal = foodItem.servingAmount * multiplier
    let isUnitMultiple = servingTotal > 1
    
    return "\(RoundingDouble(servingTotal, precision: 2)) \(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)"
}
