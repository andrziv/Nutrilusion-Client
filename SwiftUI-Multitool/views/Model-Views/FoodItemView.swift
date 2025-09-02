//
//  FoodItemView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-29.
//

import SwiftUI

struct FoodItemView: View {
    var foodItem: FoodItem
    var mealGroup: MealGroup? = nil
    @State var isExpanded: Bool = false
    var textColor: Color = .primaryText
    var subtextColor: Color = .secondaryText
    var backgroundColor: Color = .backgroundColour
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FoodItemHeader(foodItem: foodItem, mealGroup: mealGroup, isExpanded: isExpanded)
            
            if !isExpanded {
                Line()
                    .frame(height: 0.5)
                    .background(.secondaryText)
                    .opacity(0.5)
            }
            
            FoodItemBody(foodItem: foodItem, isExpanded: $isExpanded)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

struct FoodItemHeader: View {
    let foodItem: FoodItem
    let mealGroup: MealGroup?
    var isExpanded: Bool = false
    var textColour: Color = .primaryText
    var subtextColour: Color = .secondaryText
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text(foodItem.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(textColour)
                
                if !isExpanded, let mealGroup = mealGroup {
                    Text(mealGroup.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: mealGroup.colour))
                }
            }
            
            if !isExpanded {
                Spacer()
                
                ServingSizeView(foodItem: foodItem, primaryTextColor: subtextColour)
                    .labelStyle(CustomLabel(spacing: 5))
                    .font(.footnote)
            } else if let mealGroup = mealGroup {
                Spacer()
                
                Text(mealGroup.name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: mealGroup.colour))
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
                             viewType: isExpanded ? .txt : .img,
                             primaryTextColor: isExpanded ? .primaryText : .secondaryText)
            .fontWeight(isExpanded ? .semibold : .regular)
            
            if isExpanded {
                ChildNutrientRecursionView(nutrient: foodItem.nutritionList[index])
            }
        }
        .font(.footnote)
        .labelStyle(CustomLabel(spacing: 7))
    }
}

struct ChildNutrientRecursionView: View {
    let nutrient: NutrientItem
    private(set) var isOrigin: Bool = true
    
    var body: some View {
        ForEach(nutrient.childNutrients) { childNutrient in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    NutrientItemView(nutrientOfInterest: childNutrient, viewType: .txt)
                        .fontWeight(.light)
                }
                ChildNutrientRecursionView(nutrient: childNutrient, isOrigin: false)
            }
            .padding(.leading, isOrigin ? 0 : 25)
        }
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
    FoodItemView(foodItem: MockData.foodItemList[0], mealGroup: MockData.sampleMealGroup, backgroundColor: .backgroundColour)
    FoodItemView(foodItem: MockData.foodItemList[0], mealGroup: MockData.sampleMealGroup, isExpanded: true, backgroundColor: .backgroundColour)
}
