//
//  CalendarView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI

struct TimelineLogView: View {
    let selectedDate: Date
    let loggedMealItems: [LoggedMealItem]
    @Binding var isHidden: Bool
    @Binding var scrollCommand: ScrollCommand
    
    let deleteAction: (LoggedMealItem) -> Void
    
    @State private var initialScrollPerformed = false
    @State private var timeSlotScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 2.0
    private let defaultHourSpacing: CGFloat = 40
    
    private let whiteness = Color.black.opacity(0.3)
    
    private var hourSpacing: CGFloat {
        defaultHourSpacing * timeSlotScale
    }

    var body: some View {
        let animBackground = AnimatedBackgroundGradient(colours: [
            whiteness, whiteness, whiteness, .clear,
            whiteness, whiteness, whiteness, .clear,
            whiteness, whiteness, whiteness, .clear,
            whiteness, whiteness, whiteness, .clear
        ], radius: 0, cornerRadius: 7, isActive: $isHidden)
        
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical) {
                    ZStack(alignment: .topLeading) {
                        TimelineDayView(loggedMealItems: loggedMealItems,
                                        selectedDate: selectedDate,
                                        deleteAction: deleteAction,
                                        hourSpacing: hourSpacing,
                                        backgroundView: animBackground)
                        .padding([.leading, .trailing], 16)
                    }
                }
                .scrollIndicators(.hidden)
                .onChange(of: scrollCommand) { _, command in
                    ScrollCommand.scrollToHour(scrollProxy, hour: command.hour)
                }
                .onAppear {
                    ScrollCommand.scrollToHour(scrollProxy, hour: scrollCommand.hour)
                }
            }
        }
    }
}

private struct TimelineDayView<Content: View>: View {
    let loggedMealItems: [LoggedMealItem]
    let selectedDate: Date
    let deleteAction: (LoggedMealItem) -> Void
    let hourSpacing: CGFloat
    let backgroundView: Content
    
    var body: some View {
        VStack(alignment: .trailing, spacing: hourSpacing) {
            ForEach(0..<24) { hour in
                TimelineHourView(hour: hour,
                                 loggedMealItems: loggedMealItems,
                                 deleteAction: deleteAction,
                                 backgroundView: backgroundView)
            }
        }
        .padding(.bottom, 40)
    }
}

private struct TimelineHourView<Content: View>: View {
    let hour: Int
    let loggedMealItems: [LoggedMealItem]
    let deleteAction: (LoggedMealItem) -> Void
    let backgroundView: Content
    
    private var timeString: String {
        let minutes = "00"
        let twelveHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let period = hour < 12 ? "AM" : "PM"
        return "\(twelveHour):\(minutes)\(period)"
    }
    
    var body: some View {
        let filteredHourMealItems = loggedMealItems.filter({
            Calendar.current.component(.hour, from: $0.date) == hour
        })
        
        VStack {
            HStack {
                Text(timeString)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondaryText)
                    .frame(height: 30)
                    .id("hour-\(hour)")
                TimelineHourStatView(mealItems: filteredHourMealItems)
            }
            VStack(spacing: 10) {
                ForEach(filteredHourMealItems, id: \.id) { meal in
                    SwipeableRow {
                        deleteAction(meal)
                    } content: {
                        LoggedMealItemView(loggedItem: meal, backgroundView: backgroundView)
                    }
                }
            }
        }
        .padding(.vertical, filteredHourMealItems.isEmpty ? 15 : 0)
    }
}

private struct TimelineHourStatView: View {
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        if mealItems.count > 0 {
            HStack(spacing: 8) {
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .fill(.secondaryText)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(0)
                
                HStack {
                    TotalNutrientStatView(nutrientOfInterest: "Calories", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Proteins", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Fats", mealItems: mealItems)
                    TotalNutrientStatView(nutrientOfInterest: "Carbohydrates", mealItems: mealItems)
                }
                .font(.caption)
                .foregroundStyle(.secondaryText)
                .padding(.horizontal, 5)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .layoutPriority(1)  // priority for no info squashing between lines
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .fill(.secondaryText)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(0)
            }
        } else {
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .fill(.secondaryText)
                .frame(height: 1)
        }
    }
}

private struct TotalNutrientStatView: View {
    var nutrientOfInterest: String
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        if nutrientOfInterest == "Calories" {
            Label(RoundingDouble(sumCalories(mealItems)), systemImage: NutrientSymbolMapper.shared.symbol(for: "Calories"))
        } else {
            Label(RoundingDouble(sumNutrients(nutrientOfInterest, mealItems)), systemImage: NutrientSymbolMapper.shared.symbol(for: nutrientOfInterest))
        }
    }
}

#Preview{
    TimelineLogView(selectedDate: Date(),
                    loggedMealItems: MockData.loggedMeals,
                    isHidden: .constant(false),
                    scrollCommand: .constant(ScrollCommand(hour: 0))) { _ in
        
    }
}
