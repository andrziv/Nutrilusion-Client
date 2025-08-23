//
//  NutrientTreeView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-16.
//

import SwiftUI

fileprivate enum DisableReason {
    case alreadyAdded
    case isBroadCategory
    case none
    
    var title: String {
        switch self {
        case .alreadyAdded:
            return "Already Added"
        case .isBroadCategory:
            return "Not Addable"
        case .none:
            return "Ready to be Added"
        }
    }
    
    var iconName: String {
        switch self {
        case .alreadyAdded:
            return "circle.fill"
        case .isBroadCategory:
            return "circle.slash"
        case .none:
            return "circle.dashed"
        }
    }
    
    var iconColour: Color {
        switch self {
        case .alreadyAdded:
            return .orange
        case .isBroadCategory:
            return .red
        case .none:
            return .green
        }
    }
}

struct NutrientTreeButtonView: View {
    var nutrientTree: NutrientTree = .shared
    @Binding var foodItem: FoodItem
    @Binding var isShowing: Bool
    @State private var searchString: String = ""
    
    private func createDisabledList() -> [String] {
        let disabledList: [String] = foodItem.getAllNutrients().map{ $0.name }
        return disabledList
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack {
                ScrollView {
                    NutrientTreeButtonChildView(nutrientName: "Nutrients", nutrientTree: nutrientTree, disabledList: createDisabledList(), isShowing: $isShowing)
                }
                
                BasicTextField(textBinding: $searchString, placeholder: "Search for nutrient")
                    .onSubmit {
                        withAnimation {
                            scrollProxy.scrollTo("nutrient-\(searchString)", anchor: .top)
                        }
                    }
            }
        }
    }
}

struct NutrientTreeButtonChildView: View {
    var nutrientName: String
    var nutrientTree: NutrientTree = .shared
    var disabledList: [String]
    @Binding var isShowing: Bool
    private(set) var depth: Int = 0
    @State private var isExpanded: Bool = true
    
    private func depthColor(_ depth: Int) -> Color {
        let hue = Double((depth * 40) % 360) / 360.0
        return Color(hue: hue, saturation: 0.25, brightness: 0.95).mix(with: .backgroundColour, by: 0.2)
    }
    
    private func getDisableReason() -> DisableReason {
        if disabledList.contains(nutrientName) {
            return .alreadyAdded
        } else if depth < 2 {
            return .isBroadCategory
        } else {
            return .none
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            NutrientTreeBlockEntryView(
                text: nutrientName,
                backgroundColour: depthColor(depth),
                isExpanded: !nutrientTree.getChildren(of: nutrientName).isEmpty ? isExpanded : nil,
                disableReason: getDisableReason()) {
                    let backgroundColour = depthColor(depth)
                    if getDisableReason() == .none {
                        Button {
                            
                        } label: {
                            Label("Add", systemImage: "plus")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondaryText)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 7).fill(backgroundColour.mix(with: .backgroundColour, by: 0.2).opacity(0.8)))
                                .padding(.horizontal)
                        }
                    }
                    
                    if isExpanded {
                        ForEach(nutrientTree.getChildren(of: nutrientName), id: \.self) { child in
                            NutrientTreeButtonChildView(
                                nutrientName: child,
                                nutrientTree: nutrientTree,
                                disabledList: disabledList,
                                isShowing: $isShowing,
                                depth: depth + 1
                            )
                            
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .id("nutrient-\(nutrientName)")
        }
        .padding(.vertical, CGFloat(depth) + 1)
    }
}

fileprivate struct NutrientTreeBlockEntryView<Content: View>: View {
    let text: String
    let backgroundColour: Color
    var isExpanded: Bool? // nil if no children
    var disableReason: DisableReason
    let content: Content
    
    init(text: String, backgroundColour: Color, isExpanded: Bool?, disableReason: DisableReason = .none, @ViewBuilder content: () -> Content) {
        self.text = text
        self.backgroundColour = backgroundColour
        
        self.isExpanded = isExpanded
        self.disableReason = disableReason
        
        self.content = content()
    }
    
    var body: some View {
        VStack {
            NutrientTreeBlockEntryHeaderView(text: text, backgroundColour: backgroundColour, isExpanded: isExpanded)
            
            HStack {
                AddabilityReasonView(isActive: disableReason == .isBroadCategory, disableReason: .isBroadCategory, backgroundColour: backgroundColour)
                AddabilityReasonView(isActive: disableReason == .alreadyAdded, disableReason: .alreadyAdded, backgroundColour: backgroundColour)
                AddabilityReasonView(isActive: disableReason == .none, disableReason: .none, backgroundColour: backgroundColour)
            }
            .scaledToFit()
            .minimumScaleFactor(0.4)
            .padding(.horizontal)
            
            content
        }
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: isExpanded == nil ? 0 : 6))
                .foregroundStyle(backgroundColour.mix(with: .backgroundColour, by: 0.5))
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.interpolatingSpring(mass: 1, stiffness: 188, damping: 23), value: isExpanded)
    }
}

fileprivate struct AddabilityReasonView: View {
    var isActive: Bool = true
    var disableReason: DisableReason
    var backgroundColour: Color = .clear
    
    var body: some View {
        HStack {
            Image(systemName: disableReason.iconName)
                .foregroundStyle(isActive ? disableReason.iconColour : .secondaryText)
            
            if isActive {
                Text(disableReason.title)
            }
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(.secondaryText)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(RoundedRectangle(cornerRadius: 7).fill(backgroundColour.mix(with: .backgroundColour, by: 0.2).opacity(0.5)))
    }
}

struct NutrientTreeBlockEntryHeaderView: View {
    let text: String
    let backgroundColour: Color
    let isExpanded: Bool? // nil if no children
    
    var body: some View {
        HStack {
            if let expanded = isExpanded {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.primaryText)
            }
            
            Text(text)
                .fontWeight(isExpanded == nil ? .regular : .semibold)
                .foregroundStyle(.primaryText)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Rectangle().fill(backgroundColour).blur(radius: 40))
    }
}

#Preview {
    NutrientTreeButtonView(foodItem: .constant(MockData.sampleFoodItem), isShowing: .constant(true))
        .padding(.horizontal)
}
