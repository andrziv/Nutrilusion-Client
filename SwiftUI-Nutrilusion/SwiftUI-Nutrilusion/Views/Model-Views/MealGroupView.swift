//
//  MealGroupView.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-08-02.
//

import SwiftUI

struct MealGroupView: View {
    @ObservedObject var viewModel: NutrilusionFoodViewModel
    var group: MealGroup
    
    var editingAllowed: Bool = false
    @State var isExpanded: Bool = false
    
    var foodTapAction: (FoodItem) -> Void = { _ in }
    var deleteGroupAction: ((MealGroup) -> Void)? = nil
    var deleteItemAction: (FoodItem) -> Void = { _ in }
    
    var body: some View {
        let emblem = Color(hex: group.colour)
        
        VStack(spacing: 0) {
            MealGroupHeader(group: group, isExpanded: $isExpanded, emblem: emblem, deleteAction: deleteGroupAction)
                .background(emblem.opacity(0.4))
            
            MealGroupBody(viewModel: viewModel,
                          group: group,
                          editingAllowed: editingAllowed,
                          isExpanded: isExpanded,
                          emblem: emblem,
                          foodTapAction: foodTapAction,
                          deleteItemAction: deleteItemAction)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .opacity
            ))
        }
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(.primaryComplement)
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
        .onChange(of: group.foodIDs) {
            isExpanded = !group.foodIDs.isEmpty
        }
    }
}

struct MealGroupHeader: View {
    let group: MealGroup
    @Binding var isExpanded: Bool
    let emblem: Color
    
    let deleteAction: ((MealGroup) -> Void)?
    
    var body: some View {
        HStack {
            Text(group.name)
                .font(.headline)
                .foregroundStyle(.primaryText)
            
            Spacer()
            
            if let deleteAction, group.foodIDs.isEmpty {
                Button {
                    deleteAction(group)
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(emblem.mix(with: .primaryText, by: 0.3))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            } else {
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
        }
        .padding(.vertical, isExpanded ? 8 : nil)
        .padding(.horizontal)
    }
}

struct MealGroupBody: View {
    @ObservedObject var viewModel: NutrilusionFoodViewModel
    let group: MealGroup
    let editingAllowed: Bool
    let isExpanded: Bool
    let emblem: Color
    
    let foodTapAction: (FoodItem) -> Void
    let deleteItemAction: (FoodItem) -> Void
    
    var body: some View {
        if isExpanded {
            LazyVScroll(items: viewModel.foods(in: group), spacing: 12) { meal in
                SwipeableRow {
                    deleteItemAction(meal)
                } content: {
                    Button {
                        foodTapAction(meal)
                    } label: {
                        FoodItemView(foodItem: meal, viewModel: viewModel, editingAllowed: editingAllowed)
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .padding()
            .frame(maxHeight: 600)
        }
    }
}


#Preview {
    let mealGroup = MockData.sampleMealGroup
    let mockViewModel = NutrilusionFoodViewModel(repository: MockFoodRepository())
    MealGroupView(viewModel: mockViewModel, group: mealGroup)
    MealGroupView(viewModel: mockViewModel, group: mealGroup, editingAllowed: true, isExpanded: true)
}
