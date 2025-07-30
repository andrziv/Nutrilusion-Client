//
//  FoodItemView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

// TODO: make it use FoodItems...
struct FoodItemView: View {
    
    let loggedItem: LoggedMealItem
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loggedItem.meal.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                let shownNutrients = min(3, loggedItem.meal.nutritionList.count)
                
                HStack(spacing: 20) {
                    ForEach(0..<shownNutrients, id: \.self) { index in
                        Label(String(loggedItem.meal.nutritionList[index].amount), systemImage: "flame.fill")
                    }
                    
                    let servingTotal = loggedItem.servingMultiple * loggedItem.meal.servingAmount
                    let isInteger = servingTotal.truncatingRemainder(dividingBy: 1) == 0
                    Label("\(isInteger ? String(Int(servingTotal)) : String(format: "%.1f", servingTotal)) \(loggedItem.meal.servingUnit)", systemImage: "dot.square")
                }
                .foregroundStyle(.gray)
                .font(.caption)
            }
            
            
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
        .padding()
        .background(LinearGradient(colors: [.black, .black, .black, .black, loggedItem.emblemColour], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(30)
    }
}

struct ExpandedFoodItemView: View {
    
    let loggedItem: LoggedMealItem
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loggedItem.meal.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                let shownNutrients = min(3, loggedItem.meal.nutritionList.count)
                
                HStack(spacing: 20) {
                    ForEach(0..<shownNutrients, id: \.self) { index in
                        Label(String(loggedItem.meal.nutritionList[index].amount), systemImage: "flame.fill")
                    }
                    
                    let servingTotal = loggedItem.servingMultiple * loggedItem.meal.servingAmount
                    let isInteger = servingTotal.truncatingRemainder(dividingBy: 1) == 0
                    Label("\(isInteger ? String(Int(servingTotal)) : String(format: "%.1f", servingTotal)) \(loggedItem.meal.servingUnit)", systemImage: "dot.square")
                }
                .foregroundStyle(.gray)
                .font(.caption)
            }
            
            
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
        .padding()
        .background(LinearGradient(colors: [.black, .black, .black, .black, loggedItem.emblemColour], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(30)
    }
}

#Preview {
    FoodItemView(loggedItem: MockData.loggedMeals[0])
    ExpandedFoodItemView(loggedItem: MockData.loggedMeals[0])
}
