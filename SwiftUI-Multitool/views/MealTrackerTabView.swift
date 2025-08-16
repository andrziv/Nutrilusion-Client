//
//  CalorieTrackerTabView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import SwiftUI

fileprivate enum TabbedItems: Int, CaseIterable {
    case logger = 0
    case tracker
    case settings
    
    var title: String {
        switch self {
        case .logger:
            return "Food Log"
        case .tracker:
            return "Tracker"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String {
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
            //  BackgroundView()
            
            VStack() {
                // kludge around TabView because getting around the fixed-window of the main screens is too complicated.
                ZStack {
                    contentView(for: selectedTab)
                        .transition(.scale(scale: 0.99).combined(with: .opacity))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating tab bar
                HStack(spacing: 0) {
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
                        
                        if item != TabbedItems.allCases.last! {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 7)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
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
        LocationAwareBackground()
            .overlay(.ultraThinMaterial)
            .ignoresSafeArea(edges: .all)
    }
}

extension MealTrackerTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        Label(title, systemImage: imageName)
            .fontWeight(isActive ? .semibold : .regular)
            .foregroundStyle(.primaryText)
            .font(.system(size: 14))
            .padding(10)
            .background(isActive ? .blue.opacity(0.4) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    MealTrackerTabView()
}
