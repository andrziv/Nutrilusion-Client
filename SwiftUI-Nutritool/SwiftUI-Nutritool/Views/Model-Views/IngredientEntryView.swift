//
//  IngredientEntryView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-10-02.
//

import SwiftUI

struct IngredientEntryView: View {
    @Binding var ingredientEntry: IngredientEntry
    let latestVersionOfIngredient: Int
    var associatedGroup: MealGroup?
    @State private var newServingAmount: Double
    
    var showGroupInfo: Bool
    @State var isExpanded: Bool
    
    var textColor: Color
    var subtextColor: Color
    var backgroundColor: Color
    
    init(ingredientEntry: Binding<IngredientEntry>, latestVersionOfIngredient: Int, associatedGroup: MealGroup? = nil,
         showGroupInfo: Bool = false, isExpanded: Bool = false,
         textColor: Color = .primaryText, subtextColor: Color = .secondaryText, backgroundColor: Color = .backgroundColour) {
        self._ingredientEntry = ingredientEntry
        self.latestVersionOfIngredient = latestVersionOfIngredient
        self.associatedGroup = associatedGroup
        self.newServingAmount = ingredientEntry.wrappedValue.ingredient.servingAmount * ingredientEntry.wrappedValue.servingMultiplier
        
        self.showGroupInfo = showGroupInfo
        self.isExpanded = isExpanded
        
        self.textColor = textColor
        self.subtextColor = subtextColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let foodItem = ingredientEntry.ingredient
            IngredientEntryHeader(foodItem: foodItem,
                                  mealGroup: associatedGroup,
                                  mostCurrentVersion: latestVersionOfIngredient,
                                  showGroupInfo: showGroupInfo,
                                  isExpanded: isExpanded)
            
            if !isExpanded {
                Line()
                    .frame(height: 0.5)
                    .background(.secondaryText)
                    .opacity(0.5)
            }

            GranularValueTextField(value: $newServingAmount, background: .secondaryText.mix(with: .secondaryComplement, by: 0.8), unitText: foodItem.servingUnitMultiple)
                .onChange(of: newServingAmount) { _, newServing in
                    ingredientEntry.servingMultiplier = newServing / ingredientEntry.ingredient.servingAmount
                }
            
            IngredientEntryBody(foodItem: foodItem, multiplier: ingredientEntry.servingMultiplier, isExpanded: $isExpanded)
        }
        .padding()
        .background(.secondaryComplement)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

private struct IngredientEntryHeader: View {
    let foodItem: FoodItem
    let mealGroup: MealGroup?
    let mostCurrentVersion: Int
    let showGroupInfo: Bool
    var isExpanded: Bool = false
    var textColour: Color = .primaryText
    var subtextColour: Color = .secondaryText
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(foodItem.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(textColour)
                
                if let mealGroup = mealGroup, showGroupInfo {
                    Spacer()
                    
                    Text(mealGroup.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: mealGroup.colour))
                }
            }
            
            if mostCurrentVersion > foodItem.version {
                let versionDifference = mostCurrentVersion - foodItem.version
                let versionUnit = versionDifference > 1 ? "s" : ""
                Text("\(versionDifference) Version\(versionUnit) Behind")
                    .foregroundStyle(.primaryText)
                    .padding(.horizontal, 5)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .background(Capsule().fill(.orange))
            }
        }
    }
}

private struct IngredientEntryBody: View {
    let foodItem: FoodItem
    let multiplier: Double
    @Binding var isExpanded: Bool
    var textColour: Color = .primaryText
    var subtextColour: Color = .secondaryText
    
    var body: some View {
        SwappingVHStack(vSpacing: 8, hSpacing: 10, hAlignment: .top, vAlignment: .leading, useHStack: !isExpanded) {
            if !foodItem.nutritionList.isEmpty {
                IngredientNutrientShowcase(foodItem: foodItem, multiplier: multiplier, isExpanded: isExpanded)
            }
            
            if isExpanded {
                if !foodItem.ingredientList.isEmpty {
                    SubIngredientShowcase(foodItem: foodItem, multiplier: multiplier)
                }
                
                ExpandedIngredientEntryControlRow(foodItem: foodItem, isExpanded: $isExpanded)
            } else {
                Spacer()
                
                MinimizedIngredientEntryControlRow(isExpanded: $isExpanded)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .opacity
        ))
        .padding(.top, 8)
    }
}

private struct IngredientNutrientShowcase: View {
    let foodItem: FoodItem
    let multiplier: Double
    let isExpanded: Bool
    
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
                        multiplier: multiplier,
                        viewType: isExpanded ? .txt : .img,
                        primaryTextColor: isExpanded ? .primaryText : .secondaryText)
        .labelStyle(CustomLabel(spacing: 7))
        .font(.footnote)
        .fontWeight(isExpanded ? .bold : .regular)
        
        ForEach(0..<shownNutrients, id: \.self) { index in
            NutrientItemView(nutrientOfInterest: foodItem.nutritionList[index],
                             multiplier: multiplier,
                             viewType: isExpanded ? .txt : .img,
                             primaryTextColor: isExpanded ? .primaryText : .secondaryText)
            .fontWeight(isExpanded ? .semibold : .regular)
            
            if isExpanded {
                ChildNutrientRecursionView(nutrient: foodItem.nutritionList[index], multiplier: multiplier)
            }
        }
        .font(.footnote)
        .labelStyle(CustomLabel(spacing: 7))
    }
}

private struct ChildNutrientRecursionView: View {
    let nutrient: NutrientItem
    let multiplier: Double
    private(set) var isOrigin: Bool = true
    
    var body: some View {
        ForEach(nutrient.childNutrients) { childNutrient in
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    NutrientItemView(nutrientOfInterest: childNutrient, multiplier: multiplier, viewType: .txt)
                }
                .foregroundStyle(.primaryText)
                .fontWeight(.light)
                
                ChildNutrientRecursionView(nutrient: childNutrient, multiplier: multiplier, isOrigin: false)
            }
            .padding(.leading, isOrigin ? 0 : 25)
        }
    }
}

private struct SubIngredientShowcase: View {
    let foodItem: FoodItem
    let multiplier: Double
    
    var body: some View {
        Text("Ingredients")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.primaryText)
            .padding(.top, 6)
        
        ForEach(foodItem.ingredientList) { ingredient in
            HStack {
                Text(ingredient.ingredient.name)
                    .font(.footnote)
                    .foregroundStyle(.secondaryText)
                
                Spacer()
                
                Text(ServingSizeText(ingredient.ingredient, multiplier: multiplier))
                    .font(.footnote)
                    .foregroundStyle(.secondaryText)
            }
        }
    }
}

private struct MinimizedIngredientEntryControlRow: View {
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
                    Capsule()
                        .fill(.secondaryText)
                        .opacity(0.2)
                })
        }
    }
}

private struct ExpandedIngredientEntryControlRow: View {
    var foodItem: FoodItem
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
        }
    }
}

#Preview {
    @Previewable @State var ingredientEntry1 = IngredientEntry(ingredient: MockData.sampleFoodItem, servingMultiplier: 2)
    @Previewable @State var ingredientEntry2 = IngredientEntry(ingredient: MockData.sampleFoodItem, servingMultiplier: 2)
    IngredientEntryView(ingredientEntry: $ingredientEntry1,
                        latestVersionOfIngredient: 0,
                        associatedGroup: nil,
                        showGroupInfo: false,
                        backgroundColor: .backgroundColour)
    IngredientEntryView(ingredientEntry: $ingredientEntry2,
                        latestVersionOfIngredient: 1,
                        associatedGroup: MockData.sampleMealGroup,
                        showGroupInfo: true,
                        isExpanded: true,
                        backgroundColor: .backgroundColour)
}
