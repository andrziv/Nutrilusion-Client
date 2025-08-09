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
        let emblem = loggedItem.emblemColour
        let mixed = emblem.mix(with: .black, by: 0.3)
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
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                }
                
                let shownNutrients = min(3, loggedItem.meal.nutritionList.count)
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        MealCalorieStatView(mealItem: loggedItem)
                            .labelStyle(CustomLabel(spacing: 7))
                        ForEach(0..<shownNutrients, id: \.self) { index in
                            MealNutrientItemView(nutrientOfInterest: loggedItem.meal.nutritionList[index], mealItem: loggedItem)
                                .labelStyle(CustomLabel(spacing: 7))
                        }
                    }
                    
                    MealServingSizeView(mealItem: loggedItem)
                        .labelStyle(CustomLabel(spacing: 5))
                }
                .foregroundStyle(.white)
                .font(.footnote)
            }
        }
        .padding()
        .background(AnimatedBackgroundGradient(colours: [
            mixed, mixed, mixed, emblem,
            mixed, mixed, mixed, emblem,
            mixed, mixed, mixed, emblem,
            mixed, mixed, mixed, emblem
        ], radius: 0, cornerRadius: 10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    LoggedMealItemView(loggedItem: MockData.loggedMeals[0])
}
