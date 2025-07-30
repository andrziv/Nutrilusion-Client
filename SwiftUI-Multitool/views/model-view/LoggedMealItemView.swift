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
                
                HStack(spacing: 20) {
                    ForEach(0..<shownNutrients, id: \.self) { index in
                        Label(String(loggedItem.meal.nutritionList[index].amount), systemImage: "flame.fill")
                    }
                    
                    let servingTotal = loggedItem.servingMultiple * loggedItem.meal.servingAmount
                    let isInteger = servingTotal.truncatingRemainder(dividingBy: 1) == 0
                    let isUnitMultiple = servingTotal > 1
                    Label("\(isInteger ? String(Int(servingTotal)) : String(format: "%.1f", servingTotal)) \(isUnitMultiple ? loggedItem.meal.servingUnitMultiple : loggedItem.meal.servingUnit)", systemImage: "dot.square")
                }
                .foregroundStyle(.gray)
                .font(.caption)
            }
        }
        .padding()
        .background(LinearGradient(colors: [.black, .black, .black, .black, loggedItem.emblemColour], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(30)
    }
}

#Preview {
    LoggedMealItemView(loggedItem: MockData.loggedMeals[0])
}
