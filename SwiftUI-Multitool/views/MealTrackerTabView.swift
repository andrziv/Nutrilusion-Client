//
//  CalorieTrackerTabView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable{
    case logger = 0
    case tracker
    case settings
    
    var title: String{
        switch self {
        case .logger:
            return "Food Log"
        case .tracker:
            return "Tracker"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String{
        switch self {
        case .logger:
            return "clock"
        case .tracker:
            return "chart.xyaxis.line"
        case .settings:
            return "gearshape"
        }
    }
}

struct MealTrackerTabView: View {
    @State private var selectedTab: TabbedItems = .logger
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
            
            VStack() {
                // kludge around TabView because getting around the fixed-window of the main screens is too complicated.
                ZStack {
                    contentView(for: selectedTab)
                        .transition(.scale(scale: 0.99).combined(with: .opacity))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating tab bar
                HStack(spacing: 30) {
                    ForEach(TabbedItems.allCases, id: \.self) { item in
                        Button {
                            withAnimation(.snappy) {
                                selectedTab = item
                            }
                        } label: {
                            CustomTabItem(
                                imageName: item.iconName,
                                title: item.title,
                                isActive: selectedTab == item
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
    }
}

@ViewBuilder
private func contentView(for tab: TabbedItems) -> some View {
    switch tab {
    case .logger:
        LoggerView()
    case .tracker:
        TrackerView()
    case .settings:
        SettingsView()
    }
}

struct BackgroundView: View {
    var body: some View {
        SwiftUI.TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince1970
            let offsetX = Float(sin(time)) * 0.1
            let offsetY = Float(cos(time)) * 0.1
            
            MeshGradient(
                width: 4,
                height: 4,
                points: [
                    [0.0, 0.0],
                    [0.3, 0.0],
                    [0.7, 0.0],
                    [1.0, 0.0],
                    [0.0, 0.3],
                    [0.2 + offsetX, 0.4 + offsetY],
                    [0.7 + offsetX, 0.2 + offsetY],
                    [1.0, 0.3],
                    [0.0, 0.7],
                    [0.3 + offsetX, 0.8],
                    [0.7 + offsetX, 0.6],
                    [1.0, 0.7],
                    [0.0, 1.0],
                    [0.3, 1.0],
                    [0.7, 1.0],
                    [1.0, 1.0]
                ],
                colors: [
                    .purple, .indigo, .purple, .yellow,
                    .pink, .purple, .pink, .yellow,
                    .orange, .pink, .yellow, .orange,
                    .yellow, .orange, .pink, .purple
                ]
            )
        }
        .ignoresSafeArea()
        .blur(radius: 100)
    }
}

extension MealTrackerTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        HStack {
            Label(title, systemImage: imageName)
                .foregroundColor(isActive ? .black : .gray)
                .font(.system(size: 14))
        }
        .padding(10)
        .background(isActive ? .blue.opacity(0.4) : .clear)
        .cornerRadius(15)
    }
}

#Preview {
    MealTrackerTabView()
}
