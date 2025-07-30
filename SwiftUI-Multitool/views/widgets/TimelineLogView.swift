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
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            TimelineView(loggedMealItems: loggedMealItems,
                                         selectedDate: selectedDate,
                                         hourSpacing: hourSpacing)
                                .padding([.leading, .trailing], 16)
                        }
                    }
                    .onAppear {
                        if !initialScrollPerformed {
                            let calendar = Calendar.current
                            let currentHour = calendar.component(.hour, from: Date())
                            
                            let targetHour = max(currentHour - 2, 0)
                            
                            scrollProxy.scrollTo("hour-\(targetHour)", anchor: .top)
                            initialScrollPerformed = true
                            
                        }
                    }
                }
            }
        }
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
}


struct TimelineView: View {
    var loggedMealItems: [LoggedMealItem]
    let selectedDate: Date
    let hourSpacing: CGFloat
    
    var body: some View {
        VStack(alignment: .trailing, spacing: hourSpacing) {
            let filteredMeals = loggedMealItems.filter {
                let calendar = Calendar.current
                return calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
            ForEach(0..<25) { hour in
                TimelineHourView(hour: hour, loggedMealItems: filteredMeals)
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
        VStack {
            HStack {
                Text(timeString + amPm)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(height: 30)
                    .id("hour-\(hour)")
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(height: 1)
            }
            VStack(spacing: 10) {
                ForEach(loggedMealItems, id: \.id) { meal in
                    if Calendar.current.component(.hour, from: meal.date) == hour {
                        LoggedMealItemView(loggedItem: meal)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical,15)
    }
}

#Preview{
    TimelineLogView(selectedDate: Date(), loggedMealItems: .constant(MockData.loggedMeals))
}
