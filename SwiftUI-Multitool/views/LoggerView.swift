//
//  ContentView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-10.
//

import SwiftUI

struct LoggerView: View {
    
    @State var selectedDay = "Monday"
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.9, green: 0.9, blue: 0.9)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            VStack {
                VStack {
                    Text(selectedDay)
                    VStack {
                        WeekDayButtonSet(selectedDay: $selectedDay)
                            .frame(maxWidth: .infinity)
                        
                        TimelineLogView(selectedDate: Date())
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
                }
                
            }
            .padding()
        }
    }
}


struct WeekDayButtonSet: View {
    
    @Binding var selectedDay: String
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                selectedDay = "Monday"
            } label: {
                PositionalButtonView(text: "Mon", position: -1)
            }
            Button {
                selectedDay = "Tuesday"
            } label: {
                PositionalButtonView(text: "Tue", position: 0)
            }
            Button {
                selectedDay = "Wednesday"
            } label: {
                PositionalButtonView(text: "Wed", position: 0)
            }
            Button {
                selectedDay = "Thursday"
            } label: {
                PositionalButtonView(text: "Thur", position: 0)
            }
            Button {
                selectedDay = "Friday"
            } label: {
                PositionalButtonView(text: "Fri", position: 0)
            }
            Button {
                selectedDay = "Saturday"
            } label: {
                PositionalButtonView(text: "Sat", position: 0)
            }
            Button {
                selectedDay = "Sunday"
            } label: {
                PositionalButtonView(text: "Sun", position: 1)
            }
        }
    }
}

struct PositionalButtonView: View {
    var text: String
    var position: Int
    
    private func getPositionShape() -> AnyShape {
        if position < 0 {
            return AnyShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 20)))
        } else if position == 0 {
            return AnyShape(Rectangle())
        } else {
            return AnyShape(UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 20, topTrailing: 20)))
        }
    }
    
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(.white)
            .foregroundColor(.gray)
            .font(.system(size: 20, weight: .bold, design: .default))
            .clipShape(
                getPositionShape()
            )
            .overlay(
                getPositionShape()
                    .stroke(.green, lineWidth: 2)
            )
        
    }
}

#Preview {
    LoggerView()
}
