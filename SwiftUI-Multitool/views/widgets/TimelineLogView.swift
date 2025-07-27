//
//  CalendarView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-26.
//

import SwiftUI

struct TimelineLogView: View {
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
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .topLeading) {
                            TimelineView(hourSpacing: hourSpacing)
                                .padding([.leading], 16)
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
    var formattedHour: String = "%d:00"
    
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
            HStack(alignment: .top, spacing: 5) {
                VStack(spacing: 10) {
                    ForEach(CalendarTask.sampleTasks, id: \.id) { task in
                        if Calendar.current.component(.hour, from: task.startTime) == hour {
                            TaskView(task: task)
                        }
                    }
                }
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
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
                    .foregroundColor(.black)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black)
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
                title: "Team Stand-up MeetingXXX",
                description: "Review progress and plan tasks for the week",
                startTime: time(hour: 9),
                duration: 3600,
                color: .purple
            ),
            CalendarTask(
                title: "Team Stand-up Meeting",
                description: "Review progress and plan tasks for the week",
                startTime: time(hour: 9, minute: 2),
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
    TimelineLogView(selectedDate: Date())
}
