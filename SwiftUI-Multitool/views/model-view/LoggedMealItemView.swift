//
//  LoggedMealItemView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

struct LoggedMealItemView: View {
    
    let loggedItem: LoggedMealItem
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        let mixedColour = loggedItem.emblemColour.mix(with: .black, by: 0.3)
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loggedItem.meal.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    let calendar = Calendar.current
                    let date = loggedItem.date
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    Text("\(hour > 12 ? hour - 12 : hour):\(minute < 10 ? "0" : "")\(minute) \(amPm(hour: hour))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor((Color(red: 0.85, green: 0.85, blue: 0.85)))
                    
                }
                
                let shownNutrients = min(3, loggedItem.meal.nutritionList.count)
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        NutrientStatView(nutrientOfInterest: "Calories", mealItem: loggedItem)
                        ForEach(0..<shownNutrients, id: \.self) { index in
                            NutrientStatView(nutrientOfInterest: loggedItem.meal.nutritionList[index].name, mealItem: loggedItem)
                        }
                    }
                    
                    ServingSizeView(mealItem: loggedItem)
                }
                .foregroundStyle(.white)
                .font(.footnote)
            }
        }
        .padding()
        .background(LinearGradient(colors: [mixedColour, mixedColour, mixedColour, mixedColour, loggedItem.emblemColour], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
    }
}

struct NutrientStatView: View {
    var nutrientOfInterest: String
    var mealItem: LoggedMealItem
    
    var body: some View {
        if nutrientOfInterest == "Calories" {
            Label(String(getCalories(mealItem)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
        } else {
            Label(String(getNutrientValue(nutrientOfInterest, mealItem)), systemImage: NutrientImageMapping.allCases[nutrientOfInterest] ?? "questionmark.diamond.fill")
        }
    }
}

struct ServingSizeView: View {
    var mealItem: LoggedMealItem
    
    var body: some View {
        let servingTotal = mealItem.servingMultiple * mealItem.meal.servingAmount
        let isInteger = servingTotal.truncatingRemainder(dividingBy: 1) == 0
        let isUnitMultiple = servingTotal > 1
        Label("\(isInteger ? String(Int(servingTotal)) : String(format: "%.1f", servingTotal)) " +
              "\(isUnitMultiple ? mealItem.meal.servingUnitMultiple : mealItem.meal.servingUnit)",
              systemImage: "dot.square")
    }
}

#Preview {
    LoggedMealItemView(loggedItem: MockData.loggedMeals[0])
}
