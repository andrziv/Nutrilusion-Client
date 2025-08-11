//
//  FoodItemView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

struct FoodItemView: View {
    @State var foodItem: FoodItem
    @State var isExpanded: Bool = false
    var textColor: Color = .primaryText
    var subtextColor: Color = .secondaryText
    var backgroundColor: Color = .backgroundColour
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FoodItemHeader(foodItem: foodItem, isExpanded: isExpanded)
            
            if !isExpanded {
                Line()
                    .frame(height: 1)
                    .background(.secondaryText)
            }
            
            FoodItemBody(foodItem: foodItem, isExpanded: $isExpanded)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

struct FoodItemHeader: View {
    let foodItem: FoodItem
    var isExpanded: Bool = false
    var textColour: Color = .primaryText
    var subtextColour: Color = .secondaryText
    
    var body: some View {
        HStack {
            Text(foodItem.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(textColour)
            
            if !isExpanded {
                Spacer()
                
                ServingSizeView(foodItem: foodItem, primaryTextColor: subtextColour)
                    .labelStyle(CustomLabel(spacing: 5))
                    .font(.footnote)
            }
        }
    }
}

struct FoodItemBody: View {
    let foodItem: FoodItem
    @Binding var isExpanded: Bool
    var textColour: Color = .primaryText
    var subtextColour: Color = .secondaryText
    
    var body: some View {
        SwappingVHStack(vSpacing: 8, hSpacing: 10, hAlignment: .top, vAlignment: .leading, useHStack: !isExpanded) {
            if isExpanded {
                ServingSizeView(foodItem: foodItem,
                                viewType: isExpanded ? .txt : .img)
                .labelStyle(CustomLabel(spacing: 5))
                .font(.footnote)
                .fontWeight(isExpanded ? .bold : .regular)
            }
            
            if !foodItem.nutritionList.isEmpty {
                FoodItemNutrientShowcase(foodItem: foodItem,
                                         isExpanded: isExpanded)
                
                if !isExpanded {
                    Spacer()
                    
                    MinimizedFoodItemControlRow(isExpanded: $isExpanded)
                }
            }
            
            if isExpanded && !foodItem.ingredientList.isEmpty {
                Text("Ingredients")
                    .font(.subheadline)
                    .bold()
                    .padding(.top, 6)
                
                ForEach(foodItem.ingredientList) { ingredient in
                    Text(ingredient.name)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                ExpandedFoodItemControlRow(isExpanded: $isExpanded)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .opacity
        ))
        .padding(.top, 8)
    }
}

struct FoodItemNutrientShowcase: View {
    let foodItem: FoodItem
    var isExpanded: Bool
    
    var body: some View {
        let shownNutrients = min(isExpanded ? foodItem.nutritionList.count : 3, foodItem.nutritionList.count)
        if isExpanded {
            Text("Nutritional Information")
                .foregroundStyle(.secondaryText)
                .fontWeight(.heavy)
                .font(.subheadline)
                .padding(.vertical, 8)
        }
        
        CalorieStatView(foodItem: foodItem,
                        viewType: isExpanded ? .txt : .img,
                        primaryTextColor: isExpanded ? .primaryText : .secondaryText)
        .labelStyle(CustomLabel(spacing: 7))
        .font(.footnote)
        .fontWeight(isExpanded ? .bold : .regular)
        
        ForEach(0..<shownNutrients, id: \.self) { index in
            NutrientItemView(nutrientOfInterest: foodItem.nutritionList[index],
                             foodItem: foodItem,
                             viewType: isExpanded ? .txt : .img,
                             primaryTextColor: isExpanded ? .primaryText : .secondaryText)
            .fontWeight(isExpanded ? .semibold : .regular)
            
            if isExpanded {
                ForEach(foodItem.nutritionList[index].childNutrients) { childNutrient in
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                        NutrientItemView(nutrientOfInterest: childNutrient, foodItem: foodItem, viewType: .txt)
                            .fontWeight(.light)
                    }
                }
            }
        }
        .font(.footnote)
        .labelStyle(CustomLabel(spacing: 7))
    }
}

struct MinimizedFoodItemControlRow: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button {
            isExpanded = true
        } label: {
            Image(systemName: "chevron.down")
                .foregroundStyle(.primaryText)
                .font(.callout)
                .padding(.horizontal)
                .padding(.vertical, 4)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(.secondaryText)
                        .opacity(0.2)
                })
        }
    }
}

struct ExpandedFoodItemControlRow: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                isExpanded = false
            } label: {
                CloseButtonView()
                    .foregroundStyle(.primaryText)
                    .font(.callout)
                    .frame(maxWidth: .infinity)
            }
            
            Button {
                // TODO: Fill out later when recipe editing becomes available
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.primaryText)
                    .font(.callout)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 100)
                            .fill(.secondaryText)
                            .opacity(0.2)
                    })
            }
        }
    }
}

#Preview {
    FoodItemView(foodItem: MockData.foodItemList[0], backgroundColor: .backgroundColour)
    FoodItemView(foodItem: MockData.foodItemList[0], isExpanded: true, backgroundColor: .backgroundColour)
}
