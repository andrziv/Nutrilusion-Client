//
//  MealGroupView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-02.
//

import SwiftUI

struct MealGroupView: View {
    @ObservedObject var viewModel: NutriToolFoodViewModel
    var group: MealGroup
    
    var editingAllowed: Bool = false
    @State var isExpanded: Bool = false
    
    var foodTapAction: (FoodItem) -> Void = { _ in }
    
    var body: some View {
        let emblem = Color(hex: group.colour)
        
        VStack(spacing: 0) {
            MealGroupHeader(group: group, isExpanded: $isExpanded, emblem: emblem)
                .background(emblem.opacity(0.4))
            
            MealGroupBody(viewModel: viewModel,
                          group: group,
                          editingAllowed: editingAllowed,
                          isExpanded: isExpanded,
                          emblem: emblem,
                          foodTapAction: foodTapAction)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .opacity
            ))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.primaryComplement)
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isExpanded)
    }
}

struct MealGroupHeader: View {
    let group: MealGroup
    @Binding var isExpanded: Bool
    let emblem: Color
    
    var body: some View {
        HStack {
            Text(group.name)
                .font(.headline)
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.title2)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundStyle(emblem.mix(with: .primaryText, by: 0.3))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, isExpanded ? 8 : nil)
        .padding(.horizontal)
    }
}

struct MealGroupBody: View {
    @ObservedObject var viewModel: NutriToolFoodViewModel
    let group: MealGroup
    let editingAllowed: Bool
    let isExpanded: Bool
    let emblem: Color
    
    let foodTapAction: (FoodItem) -> Void
    
    var body: some View {
        if isExpanded {
            LazyVScroll(items: viewModel.foods(in: group), spacing: 12) { meal in
                Button {
                    foodTapAction(meal)
                } label: {
                    FoodItemView(foodItem: meal, viewModel: viewModel, editingAllowed: editingAllowed)
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
            .frame(maxHeight: 600)
        }
    }
}


#Preview {
    let mealGroup = MockData.sampleMealGroup
    let mockViewModel = NutriToolFoodViewModel(repository: MockFoodRepository())
    MealGroupView(viewModel: mockViewModel, group: mealGroup)
    MealGroupView(viewModel: mockViewModel, group: mealGroup, editingAllowed: true, isExpanded: true)
}
