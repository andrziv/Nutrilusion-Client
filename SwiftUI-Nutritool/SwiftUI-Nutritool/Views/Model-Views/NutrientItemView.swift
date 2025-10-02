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
            Label(RoundingDouble(nutrientOfInterest.amount * multiplier), systemImage: NutrientSymbolMapper.shared.symbol(for: nutrientOfInterest.name))
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

struct MealNutrientItemView: View {
    let nutrientOfInterest: NutrientItem
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount), systemImage: NutrientSymbolMapper.shared.symbol(for: nutrientOfInterest.name))
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("\(nutrientOfInterest.name)")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount)) \(nutrientOfInterest.unit.description)")
                    .foregroundStyle(secondaryTextColor)
            }
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

struct MealCalorieStatView: View {
    let mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * Double(mealItem.meal.calories)), systemImage: NutrientSymbolMapper.shared.symbol(for: "Calories"))
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Calories")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(mealItem.servingMultiple * Double(mealItem.meal.calories))) kcal")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct ServingSizeView: View {
    let foodItem: FoodItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        
        switch viewType {
        case .img:
            Label(ServingSizeText(foodItem), systemImage: "dot.square")
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Serving Size")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text(ServingSizeText(foodItem))
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct MealServingSizeView: View {
    let mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        let servingTotal = mealItem.servingMultiple * mealItem.meal.servingAmount
        let isUnitMultiple = servingTotal > 1
        switch viewType {
        case .img:
            Label("\(RoundingDouble(servingTotal)) " +
                  "\(isUnitMultiple ? mealItem.meal.servingUnitMultiple : mealItem.meal.servingUnit)",
                  systemImage: "dot.square")
            .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Serving Size")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(servingTotal)) \(isUnitMultiple ? mealItem.meal.servingUnitMultiple : mealItem.meal.servingUnit)")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

func ServingSizeText(_ foodItem: FoodItem, multiplier: Double = 1) -> String {
    let servingTotal = foodItem.servingAmount * multiplier
    let isUnitMultiple = servingTotal > 1
    
    return "\(RoundingDouble(servingTotal)) \(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)"
}
