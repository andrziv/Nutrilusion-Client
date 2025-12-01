//
//  CalorieTrackerTabView.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-07-31.
//

import SwiftUI

private enum TabbedItems: Int, CaseIterable {
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

struct NutriMainTabView: View {
    @State private var selectedTab: TabbedItems = .logger
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
                .ignoresSafeArea(.all)
            
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
                .background(.secondaryComplement)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 8)
            }
        }
    }
}

private struct BackgroundView: View {
    var body: some View {
        Color.backgroundColour
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

private extension NutriMainTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        Label(title, systemImage: imageName)
            .fontWeight(isActive ? .semibold : .regular)
            .foregroundStyle(.primaryText)
            .font(.system(size: 14))
            .padding(10)
            .background(isActive ? .blue.opacity(0.4) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

#Preview {
    NutriMainTabView()
        .environmentObject(NutrilusionFoodViewModel(repository: MockFoodRepository()))
}
