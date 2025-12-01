//
//  LoggedMealItemView.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

struct LoggedMealItemView<Content: View>: View {
    let loggedItem: LoggedMealItem
    let backgroundView: Content
    
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loggedItem.meal.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text(formattedTime(from: loggedItem.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.85))
                }
                
                let shownNutrients = min(3, loggedItem.importantNutrients.count)
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        CalorieStatView(foodItem: loggedItem.meal,
                                        multiplier: loggedItem.servingMultiple,
                                        primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                        .labelStyle(CustomLabel(spacing: 7))
                        ForEach(0..<shownNutrients, id: \.self) { index in
                            NutrientItemView(nutrientOfInterest: loggedItem.importantNutrients[index],
                                             multiplier: loggedItem.servingMultiple,
                                             primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                            .labelStyle(CustomLabel(spacing: 7))
                        }
                    }
                    
                    ServingSizeView(foodItem: loggedItem.meal,
                                    multiplier: loggedItem.servingMultiple,
                                    primaryTextColor: Color(red: 0.85, green: 0.85, blue: 0.85))
                    .labelStyle(CustomLabel(spacing: 5))
                }
                .font(.footnote)
            }
            .padding()
        }
        .background(loggedItem.getColour())
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

#Preview {
    LoggedMealItemView(loggedItem: MockData.loggedMeals[0], backgroundView: EmptyView())
}
