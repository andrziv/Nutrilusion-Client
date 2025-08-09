//
//  CalendarView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI

struct TimelineLogView: View {
    let selectedDate: Date
    @Binding var loggedMealItems: [LoggedMealItem]
    
    @State private var initialScrollPerformed = false
    @State private var timeSlotScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 2.0
    private let defaultHourSpacing: CGFloat = 40
    
    private var hourSpacing: CGFloat {
        defaultHourSpacing * timeSlotScale
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        TimelineDayView(loggedMealItems: loggedMealItems,
                                        selectedDate: selectedDate,
                                        hourSpacing: hourSpacing)
                        .padding([.leading, .trailing], 16)
                    }
                }
                .onAppear {
                    if !initialScrollPerformed {
                        let calendar = Calendar.current
                        let currentHour = calendar.component(.hour, from: Date())
                        
                        // target one hour before current for user to see a recent time
                        let targetHour = max(currentHour - 1, 0)
                        
                        scrollProxy.scrollTo("hour-\(targetHour)", anchor: .top)
                        initialScrollPerformed = true
                    }
                }
            }
        }
    }
}

struct TimelineDayView: View {
    var loggedMealItems: [LoggedMealItem]
    let selectedDate: Date
    let hourSpacing: CGFloat
    
    var body: some View {
        VStack(alignment: .trailing, spacing: hourSpacing) {
            ForEach(0..<25) { hour in
                TimelineHourView(hour: hour, loggedMealItems: loggedMealItems)
            }
        }
        .padding(.bottom, 40)
    }
}

struct TimelineHourView: View {
    let hour: Int
    var formattedHour: String = "%d:00"
    var loggedMealItems: [LoggedMealItem]
    
    
    private var timeString: String {
        String(format: formattedHour, hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour))
    }
    
    private var amPm: String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        let filteredHourMealItems = loggedMealItems.filter({
            Calendar.current.component(.hour, from: $0.date) == hour
        })
        
        VStack {
            HStack {
                Text(timeString + amPm)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(height: 30)
                    .id("hour-\(hour)")
                TimelineHourStatView(mealItems: filteredHourMealItems)
            }
            VStack(spacing: 10) {
                ForEach(filteredHourMealItems, id: \.id) { meal in
                    LoggedMealItemView(loggedItem: meal)
                }
            }
        }
        .padding(.vertical, filteredHourMealItems.isEmpty ? 15 : 0)
    }
}

struct TimelineHourStatView: View {
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        ZStack {
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
            if mealItems.count > 0 {
                HStack {
                    TotalNutrientStatView(nutrientOfInterest: "Calories", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Protein", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Fat", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Carbohydrates", mealItems: mealItems)
                }
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.horizontal, 5)
                .background(.white)
                .cornerRadius(15)
                
            }
        }
    }
}

struct TotalNutrientStatView: View {
    var nutrientOfInterest: String
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        if nutrientOfInterest == "Calories" {
            Label(RoundingDouble(sumCalories(mealItems)), systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
        } else {
            Label(RoundingDouble(sumNutrients(nutrientOfInterest, mealItems)), systemImage: NutrientImageMapping.allCases[nutrientOfInterest] ?? "questionmark.diamond.fill")
        }
    }
}

#Preview{
    TimelineLogView(selectedDate: Date(), loggedMealItems: .constant(MockData.loggedMeals))
}
