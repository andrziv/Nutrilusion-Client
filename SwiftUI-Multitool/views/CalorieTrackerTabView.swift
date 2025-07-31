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

struct CalorieTrackerTabView: View {
    @State private var selectedTab: TabbedItems = .logger
    @Namespace private var animationNamespace
    @State private var tabSwitchTrigger = UUID() // Used to re-trigger the animation
    
    private let tabBarHeight: CGFloat = 60
    private let floatingOffset: CGFloat = 12
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
            
            VStack() {
                // kludge around TabView because getting around the fixed-window of the main screens is too complicated.
                ZStack {
                    contentView(for: selectedTab)
                        .id(tabSwitchTrigger) // Re-trigger animation on tab change
                        .transition(.scale(scale: 0.98).combined(with: .opacity))
                        .animation(.spring(response: 4, dampingFraction: 2), value: tabSwitchTrigger)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating tab bar
                HStack(spacing: 30) {
                    ForEach(TabbedItems.allCases, id: \.self) { item in
                        Button {
                            withAnimation {
                                selectedTab = item
                                tabSwitchTrigger = UUID() // force new animation
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
        LinearGradient(colors: [Color(red: 0.9, green: 0.9, blue: 0.9)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}

extension CalorieTrackerTabView {
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
    CalorieTrackerTabView()
}
