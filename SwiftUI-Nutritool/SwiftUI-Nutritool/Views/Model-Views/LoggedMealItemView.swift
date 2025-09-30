//
//  LoggedMealItemView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

struct LoggedMealItemView<Content: View>: View {
    let loggedItem: LoggedMealItem
    let backgroundView: Content
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        let emblem = loggedItem.emblemColour
        
        ZStack {
            backgroundView
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loggedItem.meal.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    let calendar = Calendar.current
                    let date = loggedItem.date
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    Text("\(hour > 12 ? hour - 12 : hour):\(minute < 10 ? "0" : "")\(minute) \(amPm(hour: hour))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.85))
                }
                
                let shownNutrients = min(3, loggedItem.importantNutrients.count)
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        MealCalorieStatView(mealItem: loggedItem, primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                            .labelStyle(CustomLabel(spacing: 7))
                        ForEach(0..<shownNutrients, id: \.self) { index in
                            MealNutrientItemView(nutrientOfInterest: loggedItem.importantNutrients[index], mealItem: loggedItem, primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                                .labelStyle(CustomLabel(spacing: 7))
                        }
                    }
                    
                    MealServingSizeView(mealItem: loggedItem, primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                        .labelStyle(CustomLabel(spacing: 5))
                }
                .font(.footnote)
            }
            .padding()
        }
        .background(emblem)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

#Preview {
    LoggedMealItemView(loggedItem: MockData.loggedMeals[0], backgroundView: EmptyView())
}
