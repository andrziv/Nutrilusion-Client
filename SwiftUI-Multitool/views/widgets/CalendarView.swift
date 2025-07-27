//
//  CalendarView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI

struct TaskListView: View {
    let tasks = CalendarTask.sampleTasks
    let selectedDate: Date
    
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text("You have 5 tasks scheduled for today")
                    .font(.callout)
                    .foregroundColor(.green)
            }
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 16) {
                            
                            TimelineView(hourSpacing: hourSpacing)
                            
                            CurrentTimeIndicator(hourSpacing: hourSpacing)
                            
                            VStack(spacing: hourSpacing) {
                                ForEach(tasks) { task in
                                   // TaskView(task: task)
                                }
                            }.frame(maxWidth: .infinity)
                        }
                        .frame(minHeight: geometry.size.height)
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
        .padding()
        .background(
            ZStack {
                Color.white
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            }
        )
        .cornerRadius(20)
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
}


struct TimelineView: View {
    let hourSpacing: CGFloat
    
    var body: some View {
        VStack(alignment: .trailing, spacing: hourSpacing) {
            ForEach(0..<25) { hour in
                TimelineHourView(hour: hour)
            }
        }
        .padding(.bottom, 40)
    }
}


struct TimelineHourView: View {
    let hour: Int
    
    private var timeString: String {
        String(format: "%d:00", hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour))
    }
    
    private var amPm: String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(timeString)
            Text(amPm)
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundColor(.blue)
        .frame(height: 30)
        .id("hour-\(hour)")
    }
}


struct CurrentTimeIndicator: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
    let hourSpacing: CGFloat
    private let timelineHourHeight: CGFloat = 30
    
    private var indicatorOffset: CGFloat {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: currentTime)
        let hour = CGFloat(components.hour ?? 0)
        let minute = CGFloat(components.minute ?? 0)
        
        return (hour + minute / 60) * (hourSpacing + timelineHourHeight)
    }
    
    var body: some View {
        HStack {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color.teal)
                    .frame(width: 4, height: indicatorOffset + 10)
                    .cornerRadius(2)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.teal)
                        .frame(width: 35, height: 20)
                    
                    Text(timeString)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .offset(y: indicatorOffset)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}


struct TaskView: View {
    let task: CalendarTask
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.green)
            }
            Spacer()
            
            Button(action: {
                
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
            }
        }
        .padding()
        .background(task.color)
        .cornerRadius(10)
    }
}


struct CalendarTask: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let startTime: Date
    let duration: TimeInterval
    let color: Color
}


extension CalendarTask {
    static let sampleTasks: [CalendarTask] = {
        let calendar = Calendar.current
        let now = Date()
        
        func time(hour: Int, minute: Int = 0) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        }
        
        return [
            CalendarTask(
                title: "Team Stand-up Meeting",
                description: "Review progress and plan tasks for the week",
                startTime: time(hour: 9, minute: 30),
                duration: 3600,
                color: .purple
            ),
            
            CalendarTask(
                title: "Client Call",
                description: "Discuss project updates and next steps with the client",
                startTime: time(hour: 11),
                duration: 1800,
                color: .green
            ),
            
            CalendarTask(
                title: "Gym Workout",
                description: "Go for a 1 hour workout session",
                startTime: time(hour: 13),
                duration: 3600,
                color: .pink
            ),
            
            CalendarTask(
                title: "Vet Appointment",
                description: "Take the dog to the vet for a check-up",
                startTime: time(hour: 15, minute: 30),
                duration: 1800,
                color: .orange
            ),
            
            CalendarTask(
                title: "Design Review",
                description: "Go over the latest UI updates",
                startTime: time(hour: 17),
                duration: 3600,
                color: .blue
            )
        ]
    }()
}


#Preview{
    TaskListView(selectedDate: Date())
}
