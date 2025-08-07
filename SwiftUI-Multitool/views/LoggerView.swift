//
//  ContentView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-10.
//

import SwiftUI

struct SelectedDay {
    var day: WeekDayType
    var date: Date
}

struct WeekDayType: Hashable {
    let id: String = UUID().uuidString
    let name: String
    let shortform: String
    
    private init(_ name: String, _ shortform: String) {
        self.name = name
        self.shortform = shortform
    }
}

extension WeekDayType {
    static let monday = WeekDayType("Monday", "Mon")
    static let tuesday = WeekDayType("Tuesday", "Tue")
    static let wednesday = WeekDayType("Wednesday", "Wed")
    static let thursday = WeekDayType("Thursday", "Thur")
    static let friday = WeekDayType("Friday", "Fri")
    static let saturday = WeekDayType("Saturday", "Sat")
    static let sunday = WeekDayType("Sunday", "Sun")
    static let fullWeek = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
}

struct LoggerView: View {
    let currentDate = Date()
    @State private var selectedDay = SelectedDay(day: WeekDayType.fullWeek[Calendar.current.component(.weekday, from: Date()) - 1], date: Date())
    @State private var loggedMealItems: [LoggedMealItem] = MockData.loggedMeals
    @State private var isShowingRecipesMenu: Bool = false
    
    var body: some View {
        let filteredMeals = loggedMealItems.filter {
            let calendar = Calendar.current
            return calendar.isDate($0.date, inSameDayAs: selectedDay.date)
        }
        let filteredSortedMeals = filteredMeals.sorted { $0.date < $1.date }
        
        VStack {
            VStack {
                VStack() {
                    WeekDayButtonSet(selectedDay: $selectedDay)
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        TimelineLogHeader(selectedDay: selectedDay)
                            .padding([.trailing, .leading], 15)
                        TimelineLogView(selectedDate: selectedDay.date, loggedMealItems: .constant(filteredSortedMeals))
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                }
            }
            
            HStack {
                DailyStatProgressView(mealItems: filteredSortedMeals)
                    .padding(12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                
                Button {
                    isShowingRecipesMenu = true
                } label: {
                    LogCurrentTimeButton()
                }
            }
        }
        .padding()
        .sheet(isPresented: $isShowingRecipesMenu) {
            RecipeListView()
        }
    }
}

struct WeekDayButtonSet: View {
    
    @Binding var selectedDay: SelectedDay
    
    private func positionType(_ index: Int) -> Position {
        if index == 0 {
            return .left
        } else if index >= 6 {
            return .right
        } else {
            return .mid
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            let currentWeekDay = Calendar.current.component(.weekday, from: Date())
            let currentDayIndex = currentWeekDay == 1 ? 7 : currentWeekDay - 1
            let selectedWeekDay = Calendar.current.component(.weekday, from: selectedDay.date)
            let selectedDayIndex = selectedWeekDay == 1 ? 7 : selectedWeekDay - 1
            
            ForEach(0..<WeekDayType.fullWeek.count, id: \.self) { index in
                let day = WeekDayType.fullWeek[index]
                let date = Calendar.current.date(byAdding: .day, value: index - (currentDayIndex - 1), to: Date())!
                let calendarDay = Calendar.current.component(.day, from: date)
                
                Button {
                    selectedDay.day = day
                    selectedDay.date = date
                } label: {
                    PositionalButtonView(toptext:  String(calendarDay),
                                         maintext: day.shortform,
                                         position: positionType(index),
                                         isSelected: selectedDayIndex - 1 == index)
                }
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct TimelineLogHeader: View {
    let selectedDay: SelectedDay
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "list.clipboard")
                Text("Logged Food for " + selectedDay.date.formatted(dateMonthDayYearFormat()))
            }
            .padding(.top, 10)
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            
            Line()
                .frame(height: 1)
                .background(.gray)
        }
    }
}

struct DailyStatProgressView: View {
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        HStack {
            DailyNutrientProgressView(nutrientOfInterest: "Calories", mealItems: mealItems)
            DailyNutrientProgressView(nutrientOfInterest: "Protein", mealItems: mealItems)
            DailyNutrientProgressView(nutrientOfInterest: "Fat", mealItems: mealItems)
            DailyNutrientProgressView(nutrientOfInterest: "Carbohydrates", mealItems: mealItems)
        }
        .frame(maxHeight: 25)
    }
}

struct DailyNutrientProgressView: View {
    var nutrientOfInterest: String
    var mealItems: [LoggedMealItem]
    var progress: Double = 1
    
    var body: some View {
        VStack(spacing: 4) {
            ScaledTotalNutrientStatView(nutrientOfInterest: nutrientOfInterest, mealItems: mealItems)
                .scaledToFit()
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity)
                .font(.caption2)
            ProgressView(value: progress)
        }
    }
}

struct ScaledTotalNutrientStatView: View {
    var nutrientOfInterest: String
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        if nutrientOfInterest == "Calories" {
            Label(RoundingDouble(sumCalories(mealItems)),
                  systemImage: NutrientImageMapping.allCases["Calories"] ?? "questionmark.diamond.fill")
            .labelStyle(CustomLabel(spacing: 3))
        } else {
            Label(RoundingDouble(sumNutrients(nutrientOfInterest, mealItems)),
                  systemImage: NutrientImageMapping.allCases[nutrientOfInterest] ?? "questionmark.diamond.fill")
            .labelStyle(CustomLabel(spacing: 3))
        }
    }
}

struct LogCurrentTimeButton: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
    var body: some View {
        Label("@ " + timeString, systemImage: "plus.circle.fill")
            .padding(12)
            .foregroundColor(.black)
            .frame(maxHeight: 50)
            .background(Color(red: 0.8, green: 0.8, blue: 1),
                        in: RoundedRectangle(cornerRadius: 12))
            .fixedSize(horizontal: true, vertical: false)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
    }
}

#Preview {
    LoggerView()
}
