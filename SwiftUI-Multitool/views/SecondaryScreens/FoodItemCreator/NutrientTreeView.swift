//
//  NutrientTreeView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-16.
//

import SwiftUI

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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            NutrientTreeButtonEntryView(
                text: nutrientName,
                depth: depth,
                isExpanded: !nutrientTree.getChildren(of: nutrientName).isEmpty ? isExpanded : nil,
                isDisabled: disabledList.contains(nutrientName)) {
                    
                    if !nutrientTree.getChildren(of: nutrientName).isEmpty {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    }
                    if !disabledList.contains(nutrientName) {
                        isShowing = false
                    }
                }
                .id("nutrient-\(nutrientName)")
            
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
                .padding(.leading, 20)
            }
        }
        .padding(.vertical, depth == 0 ? 4 : 2)
    }
}

struct NutrientTreeButtonEntryView: View {
    let text: String
    let depth: Int
    let isExpanded: Bool? // nil if no children
    var isDisabled: Bool = false
    let action: () -> Void
    
    private func depthColor(_ depth: Int) -> Color {
        let hue = Double((depth * 40) % 360) / 360.0
        return Color(hue: hue, saturation: 0.25, brightness: 0.95).mix(with: .backgroundColour, by: 0.2)
    }
    
    var body: some View {
        Button(action: action) {
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
                
                Group {
                    if depth < 2 {
                        Text("Not Addable")
                    }
                    else if isDisabled {
                        Text("Already Added!")
                    }
                }
                .font(.caption)
                .foregroundStyle(.backgroundColour)
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 4).fill(.backgroundColour.mix(with: .primaryText, by: 0.55).opacity(0.35)))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(depthColor(depth))
            )
        }
    }
}

struct NutrientTreeEditorialView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text("Hi")
    }
}

#Preview {
    NutrientTreeButtonView(foodItem: .constant(MockData.sampleFoodItem), isShowing: .constant(true))
        .padding(.horizontal)
    NutrientTreeEditorialView()
}
