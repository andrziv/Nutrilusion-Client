//
//  NutrientTreeView.swift
//  SwiftUI-Nutrilusion
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
                BasicTextField("Search for nutrient", text: $searchString, cornerRadius: 7, outlineWidth: 0, background: .primaryComplement)
                    .disableAutocorrection(true)
                    .onSubmit {
                        withAnimation {
                            scrollProxy.scrollTo("nutrient-\(searchString)", anchor: .top)
                        }
                    }
                
                ScrollView {
                    NutrientTreeButtonChildView(foodItem: $foodItem, nutrientName: "Nutrients", nutrientTree: nutrientTree, disabledList: createDisabledList(), isShowing: $isShowing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .basicBackground(cornerRadius: 7, shadowRadius: 0, background: .primaryComplement)
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
    @State private var blockMode: BlockState
    
    init(foodItem: Binding<FoodItem>, nutrientName: String, nutrientTree: NutrientTree = .shared, disabledList: [String] = [], isShowing: Binding<Bool>, depth: Int = 0) {
        self._foodItem = foodItem
        
        self.nutrientName = nutrientName
        self.nutrientTree = nutrientTree
        
        self.disabledList = disabledList
        self._isShowing = isShowing
        
        self.depth = depth
        self.blockMode = !nutrientTree.getChildren(of: nutrientName).isEmpty ? .expanded : .noChildren
    }
    
    private func depthColor(_ depth: Int) -> Color {
        let hue = Double((depth * 40) % 360) / 360.0
        return Color(hue: hue, saturation: 0.25, brightness: 0.95).mix(with: .backgroundColour, by: 0.2)
    }
    
    private func getDisableReason() -> DisableReason {
        if disabledList.contains(nutrientName) {
            return .alreadyAdded
        } else if nutrientTree.findNutrient(nutrientName)!.ignoreGeneric {
            return .isBroadCategory
        } else {
            return .none
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NutrientTreeBlockEntryView(
                text: nutrientName,
                backgroundColour: depthColor(depth),
                blockMode: $blockMode,
                disableReason: getDisableReason()) {
                    let backgroundColour = depthColor(depth)
                    if getDisableReason() == .none {
                        Button {
                            foodItem.createNutrientChain(nutrientName)
                            isShowing = false
                        } label: {
                            Label("Add", systemImage: "plus")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondaryText)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 7).fill(backgroundColour.mix(with: .secondaryText, by: 0.1).opacity(0.5)))
                        }
                    }
                } content: {
                    if blockMode == .expanded {
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
                        .padding(.leading, 15)
                    }
                }
                .id("nutrient-\(nutrientName)")
        }
    }
}

fileprivate struct NutrientTreeBlockEntryView<HeaderContent: View, BodyContent: View>: View {
    let text: String
    let backgroundColour: Color
    @Binding var blockMode: BlockState
    var disableReason: DisableReason
    
    let headerContent: HeaderContent
    let content: BodyContent
    
    init(text: String, backgroundColour: Color, blockMode: Binding<BlockState>, disableReason: DisableReason = .none, @ViewBuilder headerContent: () -> HeaderContent, @ViewBuilder content: () -> BodyContent) {
        self.text = text
        self.backgroundColour = backgroundColour
        
        self._blockMode = blockMode
        self.disableReason = disableReason
        
        self.headerContent = headerContent()
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    if blockMode == .expanded {
                        blockMode = .minimized
                    } else if blockMode == .minimized {
                        blockMode = .expanded
                    }
                }
            } label: {
                NutrientTreeBlockEntryHeaderView(text: text, backgroundColour: backgroundColour, blockMode: blockMode, disableReason: disableReason, content: headerContent)
            }
            
            content
        }
    }
}

fileprivate struct NutrientTreeBlockEntryHeaderView<Content: View>: View {
    let text: String
    let backgroundColour: Color
    let blockMode: BlockState
    let disableReason: DisableReason
    
    let content: Content
    
    private func padding() -> Edge.Set {
        if disableReason == .none {
            return .top
        } else {
            if blockMode == .expanded {
                return .top
            }
            
            return .vertical
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                if blockMode != .noChildren {
                    Image(systemName: blockMode == .expanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.primaryText)
                }
                
                Text(text)
                    .font(.subheadline)
                    .scaledToFit()
                    .minimumScaleFactor(0.4)
                    .fontWeight(blockMode == .noChildren ? .regular : .semibold)
                    .foregroundStyle(.primaryText)
                
                Spacer()
                
                StatusBadge(disableReason: disableReason, backgroundColour: backgroundColour)
                    .scaledToFit()
                    .minimumScaleFactor(0.4)
            }
            
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 7).fill(backgroundColour.mix(with: .backgroundColour, by: 0.5)))
    }
}


fileprivate struct StatusBadge: View {
    var disableReason: DisableReason
    var backgroundColour: Color = .clear
    
    var body: some View {
        HStack {
            Image(systemName: disableReason.iconName)
                .foregroundStyle(disableReason.iconColour)
            
                Text(disableReason.title)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(.secondaryText)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(RoundedRectangle(cornerRadius: 7).fill(backgroundColour.mix(with: .secondaryText, by: 0.1).opacity(0.5)))
    }
}

#Preview {
    NutrientTreeButtonView(foodItem: .constant(MockData.sampleFoodItem), isShowing: .constant(true))
        .padding(.horizontal)
}
