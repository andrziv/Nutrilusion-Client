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

fileprivate enum BlockState {
    case noChildren
    case expanded
    case minimized
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
                    NutrientTreeButtonChildView(foodItem: $foodItem, nutrientName: "Nutrients", nutrientTree: nutrientTree, disabledList: createDisabledList(), isShowing: $isShowing)
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
    @Binding var foodItem: FoodItem
    var nutrientName: String
    var nutrientTree: NutrientTree = .shared
    var disabledList: [String]
    @Binding var isShowing: Bool
    private(set) var depth: Int = 0
    @State private var isExpanded: BlockState
    
    init(foodItem: Binding<FoodItem>, nutrientName: String, nutrientTree: NutrientTree = .shared, disabledList: [String] = [], isShowing: Binding<Bool>, depth: Int = 0) {
        self._foodItem = foodItem
        
        self.nutrientName = nutrientName
        self.nutrientTree = nutrientTree
        
        self.disabledList = disabledList
        self._isShowing = isShowing
        
        self.depth = depth
        self.isExpanded = !nutrientTree.getChildren(of: nutrientName).isEmpty ? .expanded : .noChildren
    }
    
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
                isExpanded: $isExpanded,
                disableReason: getDisableReason()) {
                    let backgroundColour = depthColor(depth)
                    if getDisableReason() == .none {
                        Button {
                            foodItem.nutritionList.append(NutrientItem(name: nutrientName, amount: 0, unit: "g"))
                            isShowing = false
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
                    
                    if isExpanded == .expanded {
                        ForEach(nutrientTree.getChildren(of: nutrientName), id: \.self) { child in
                            NutrientTreeButtonChildView(
                                foodItem: $foodItem,
                                nutrientName: child,
                                nutrientTree: nutrientTree,
                                disabledList: disabledList,
                                isShowing: $isShowing,
                                depth: depth + 1
                            )
                            
                            .transition(.opacity.combined(with: .blurReplace))
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .id("nutrient-\(nutrientName)")
        }
    }
}

fileprivate struct NutrientTreeBlockEntryView<Content: View>: View {
    let text: String
    let backgroundColour: Color
    @Binding var isExpanded: BlockState
    var disableReason: DisableReason
    let content: Content
    
    init(text: String, backgroundColour: Color, isExpanded: Binding<BlockState>, disableReason: DisableReason = .none, @ViewBuilder content: () -> Content) {
        self.text = text
        self.backgroundColour = backgroundColour
        
        self._isExpanded = isExpanded
        self.disableReason = disableReason
        
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Button {
                if isExpanded == .expanded {
                    isExpanded = .minimized
                } else if isExpanded == .minimized {
                    isExpanded = .expanded
                } 
            } label: {
                NutrientTreeBlockEntryHeaderView(text: text, backgroundColour: backgroundColour, isExpanded: isExpanded, disableReason: disableReason)
            }
            
            content
        }
        .padding(.bottom, isExpanded == .noChildren ? 15 : 5)
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 6))
                .foregroundStyle(backgroundColour.mix(with: .backgroundColour, by: 0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.snappy, value: isExpanded)
    }
}

fileprivate struct NutrientTreeBlockEntryHeaderView: View {
    let text: String
    let backgroundColour: Color
    let isExpanded: BlockState
    let disableReason: DisableReason
    
    var body: some View {
        VStack {
            HStack {
                if isExpanded != .noChildren {
                    Image(systemName: isExpanded == .expanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.primaryText)
                }
                
                Text(text)
                    .fontWeight(isExpanded == .noChildren ? .regular : .semibold)
                    .foregroundStyle(.primaryText)
                
                Spacer()
            }
            
            HStack {
                AddabilityReasonView(isActive: disableReason == .isBroadCategory, disableReason: .isBroadCategory, backgroundColour: backgroundColour)
                AddabilityReasonView(isActive: disableReason == .alreadyAdded, disableReason: .alreadyAdded, backgroundColour: backgroundColour)
                AddabilityReasonView(isActive: disableReason == .none, disableReason: .none, backgroundColour: backgroundColour)
            }
            .scaledToFit()
            .minimumScaleFactor(0.4)
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Rectangle().fill(backgroundColour).blur(radius: 40))
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

#Preview {
    NutrientTreeButtonView(foodItem: .constant(MockData.sampleFoodItem), isShowing: .constant(true))
        .padding(.horizontal)
}
