//
//  NutrientItemView.swift
//  SwiftUI-Multitool
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
    var foodItem: FoodItem
    var viewType : StatViewType = .img
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(nutrientOfInterest.amount), systemImage: NutrientImageMapping.allCases[nutrientOfInterest.name] ?? "questionmark.diamond.fill")
        case .txt:
            Text("\(nutrientOfInterest.name): \(RoundingDouble(nutrientOfInterest.amount))\(nutrientOfInterest.unit)")
        }
    }
}

struct MealNutrientItemView: View {
    var nutrientOfInterest: NutrientItem
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount), systemImage: NutrientImageMapping.allCases[nutrientOfInterest.name] ?? "questionmark.diamond.fill")
        case .txt:
            Text("\(nutrientOfInterest.name): \(RoundingDouble(mealItem.servingMultiple * nutrientOfInterest.amount))\(nutrientOfInterest.unit)")
        }
    }
}

struct CalorieStatView: View {
    var foodItem: FoodItem
    var viewType : StatViewType = .img
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(Double(foodItem.calories)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
        case .txt:
            Text("Calories: \(RoundingDouble(Double(foodItem.calories)))")
        }
    }
}

struct MealCalorieStatView: View {
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    
    var body: some View {
        switch viewType {
        case .img:
            Label(RoundingDouble(mealItem.servingMultiple * Double(mealItem.meal.calories)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
        case .txt:
            Text("Calories: \(RoundingDouble(mealItem.servingMultiple * Double(mealItem.meal.calories)))")
        }
    }
}

struct ServingSizeView: View {
    var foodItem: FoodItem
    var viewType : StatViewType = .img
    
    var body: some View {
        let servingTotal = foodItem.servingAmount
        let isUnitMultiple = servingTotal > 1
        switch viewType {
        case .img:
            Label("\(RoundingDouble(servingTotal)) " +
                  "\(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)",
                  systemImage: "dot.square")
        case .txt:
            Text("Serving Size: \(RoundingDouble(servingTotal)) " +
                 "\(isUnitMultiple ? foodItem.servingUnitMultiple : foodItem.servingUnit)")
        }
    }
}

struct MealServingSizeView: View {
    var mealItem: LoggedMealItem
    var viewType : StatViewType = .img
    
    var body: some View {
        let servingTotal = mealItem.servingMultiple * mealItem.meal.servingAmount
        let isUnitMultiple = servingTotal > 1
        switch viewType {
        case .img:
            Label("\(RoundingDouble(servingTotal)) " +
                  "\(isUnitMultiple ? mealItem.meal.servingUnitMultiple : mealItem.meal.servingUnit)",
                  systemImage: "dot.square")
        case .txt:
            Text("Serving Size: \(RoundingDouble(servingTotal)) " +
                 "\(isUnitMultiple ? mealItem.meal.servingUnitMultiple : mealItem.meal.servingUnit)")
        }
    }
}
