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
    @State var selectedDay = SelectedDay(day: WeekDayType.fullWeek[Calendar.current.component(.weekday, from: Date()) - 1], date: Date())
    
    var body: some View {
        VStack {
            VStack {
                VStack() {
                    WeekDayButtonSet(selectedDay: $selectedDay)
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        TimelineLogHeader(selectedDay: selectedDay)
                        
                        TimelineLogView(selectedDate: selectedDay.date, loggedMealItems: .constant(MockData.loggedMeals))
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                }
            }
            
            HStack {
                HStack {
                    VStack(spacing: 4) {
                        Label("3800", systemImage: "flame.fill")
                            .font(.subheadline)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                        ProgressView(value: 1.2)
                    }
                    VStack(spacing: 4) {
                        Label("100", systemImage: "p.circle.fill")
                            .font(.subheadline)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                        ProgressView(value: 1)
                    }
                    VStack(spacing: 4) {
                        Label("100", systemImage: "f.circle.fill")
                            .font(.subheadline)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                        ProgressView(value: 1)
                    }
                    VStack(spacing: 4) {
                        Label("100", systemImage: "c.circle.fill")
                            .font(.subheadline)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                        ProgressView(value: 1)
                    }
                }
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                
                LogCurrentTimeButton()
            }
        }
        .padding()
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
        .padding([.trailing, .leading], 15)
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
        Button(action: {
            
        }) {
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
}

#Preview {
    LoggerView()
}
