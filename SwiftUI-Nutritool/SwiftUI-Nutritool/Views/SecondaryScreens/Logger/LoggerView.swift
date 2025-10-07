//
//  ContentView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-10.
//

import SwiftUI

fileprivate struct SelectedDay {
    var day: WeekDayType
    var date: Date
}

fileprivate struct WeekDayType: Hashable {
    let id: String = UUID().uuidString
    let name: String
    let shortform: String
    
    private init(_ name: String, _ shortform: String) {
        self.name = name
        self.shortform = shortform
    }
}

fileprivate extension WeekDayType {
    static let monday = WeekDayType("Monday", "Mon")
    static let tuesday = WeekDayType("Tuesday", "Tue")
    static let wednesday = WeekDayType("Wednesday", "Wed")
    static let thursday = WeekDayType("Thursday", "Thur")
    static let friday = WeekDayType("Friday", "Fri")
    static let saturday = WeekDayType("Saturday", "Sat")
    static let sunday = WeekDayType("Sunday", "Sun")
    static let fullWeek = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
    
    static func getType(from weekdayIndex: Int) -> WeekDayType {
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default:
            return .sunday
        }
    }
}

struct LoggerView: View {
    @EnvironmentObject var foodViewModel: NutriToolFoodViewModel
    
    @State private var selectedDay = SelectedDay(
        day: WeekDayType.getType(from: Calendar.current.component(.weekday, from: Date())),
        date: Date()
    )
    
    @State private var isShowingLoggingModal: Bool = false
    
    var body: some View {
        let filteredMeals = foodViewModel.loggedMeals.filter {
            let calendar = Calendar.current
            return calendar.isDate($0.date, inSameDayAs: selectedDay.date)
        }
        let filteredSortedMeals = filteredMeals.sorted { $0.date < $1.date }
        
        VStack {
            WeekDayButtonSet(selectedDay: $selectedDay, isShowingLoggingModal: $isShowingLoggingModal)
                .frame(maxWidth: .infinity)

            Group {
                if isShowingLoggingModal {
                    LogNewItemView(viewModel: foodViewModel, logDate: Date()) {
                        withAnimation {
                            isShowingLoggingModal = false
                        }
                    } finalizeCreation: { loggedItem in
                        foodViewModel.addLoggedMeal(loggedItem)
                        isShowingLoggingModal = false
                    }
                } else {
                    VStack(spacing: 0) {
                        TimelineLogHeader(selectedDay: selectedDay)
                            .padding([.trailing, .leading], 15)
                        
                        TimelineLogView(selectedDate: selectedDay.date, loggedMealItems: filteredSortedMeals, isHidden: $isShowingLoggingModal) { deletedItem in
                            foodViewModel.removeLoggedMeal(deletedItem)
                        }
                    }
                    .background(.secondaryComplement)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))))
            .tapToHideKeyboard()
            
            SwappingVHStack(vSpacing: 8, hSpacing: 8, useHStack: !isShowingLoggingModal) {
                DailyStatProgressView(mealItems: filteredSortedMeals)
                    .padding(12)
                    .background(.secondaryComplement, in: RoundedRectangle(cornerRadius: 7))
                
                if !isShowingLoggingModal {
                    LogCurrentTimeButton() {
                        withAnimation {
                            isShowingLoggingModal.toggle()
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8)
    }
}

struct WeekDayButtonSet: View {
    @Binding fileprivate var selectedDay: SelectedDay
    @Binding var isShowingLoggingModal: Bool
    
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
                    if selectedDay.day == day {
                        withAnimation {
                            isShowingLoggingModal = false
                        }
                        return
                    }
                    selectedDay.day = day
                    selectedDay.date = date
                } label: {
                    PositionalButtonView(topText:  String(calendarDay),
                                         mainText: day.shortform,
                                         position: positionType(index),
                                         isSelected: selectedDayIndex - 1 == index,
                                         cornerRadius: 7,
                                         background: .secondaryComplement)
                }
            }
        }
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct TimelineLogHeader: View {
    fileprivate let selectedDay: SelectedDay
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Logged Food for " + selectedDay.date.formatted(dateMonthDayYearFormat()), systemImage: "list.clipboard")
                .padding(.top, 10)
                .font(.system(size: 14))
                .foregroundStyle(.secondaryText)
            
            Line()
                .frame(height: 0.5)
                .background(.secondaryText)
        }
    }
}

struct DailyStatProgressView: View {
    var mealItems: [LoggedMealItem]
    
    var body: some View {
        HStack {
            DailyNutrientProgressView(nutrientOfInterest: "Calories", mealItems: mealItems)
            DailyNutrientProgressView(nutrientOfInterest: "Proteins", mealItems: mealItems)
            DailyNutrientProgressView(nutrientOfInterest: "Fats", mealItems: mealItems)
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
                .foregroundStyle(.primaryText)
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
                  systemImage: NutrientSymbolMapper.shared.symbol(for: "Calories"))
            .labelStyle(CustomLabel(spacing: 3))
        } else {
            Label(RoundingDouble(sumNutrients(nutrientOfInterest, mealItems)),
                  systemImage: NutrientSymbolMapper.shared.symbol(for: nutrientOfInterest))
            .labelStyle(CustomLabel(spacing: 3))
        }
    }
}

private struct LogCurrentTimeButton: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    let action: () -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
    var body: some View {
        ImagedButton(title: "@ " + timeString, icon: "plus.circle.fill",
                     textFont: .callout.weight(.regular),
                     circleColour: .clear,
                     cornerRadius: 7,
                     maxWidth: 110, maxHeight: 45,
                     backgroundColour: .secondaryComplement,
                     action: action)
        .scaledToFit()
        .minimumScaleFactor(0.4)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

#Preview {
    LoggerView()
        .environmentObject(NutriToolFoodViewModel(repository: MockFoodRepository()))
}
