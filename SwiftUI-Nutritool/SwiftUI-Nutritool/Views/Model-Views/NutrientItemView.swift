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
    var nutrientOfInterest: NutrientItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(nutrientOfInterest.amount), systemImage: NutrientImageMapping.allCases[nutrientOfInterest.name] ?? "questionmark.diamond.fill")
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("\(nutrientOfInterest.name)")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(nutrientOfInterest.amount)) \(nutrientOfInterest.unit)")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct MealNutrientItemView: View {
    var nutrientOfInterest: NutrientItem
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount), systemImage: NutrientImageMapping.allCases[nutrientOfInterest.name] ?? "questionmark.diamond.fill")
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("\(nutrientOfInterest.name)")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount)) \(nutrientOfInterest.unit)")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct CalorieStatView: View {
    var foodItem: FoodItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(Double(foodItem.calories)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
                .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Calories")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(Double(foodItem.calories))) kcal")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct MealCalorieStatView: View {
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * Double(mealItem.meal.calories)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
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
    var foodItem: FoodItem
    var viewType : StatViewType = .img
    var primaryTextColor: Color = .primaryText
    var secondaryTextColor: Color = .secondaryText
    
    var body: some View {
        let servingTotal = foodItem.servingAmount
        let isUnitMultiple = servingTotal > 1
        switch viewType {
        case .img:
            Label("\(RoundingDouble(servingTotal)) " +
                  "\(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)",
                  systemImage: "dot.square")
            .foregroundStyle(primaryTextColor)
        case .txt:
            HStack {
                Text("Serving Size")
                    .foregroundStyle(primaryTextColor)
                
                Spacer()
                
                Text("\(RoundingDouble(servingTotal)) \(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)")
                    .foregroundStyle(secondaryTextColor)
            }
        }
    }
}

struct MealServingSizeView: View {
    var mealItem: LoggedMealItem
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
