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
        ZStack {
            if isExpanded {
                ExpandedFoodItemView(foodItem: foodItem,
                                     textColor: textColor,
                                     subtextColor: subtextColor,
                                     backgroundColor: backgroundColor,
                                     isExpanded: $isExpanded)
                .transition(.opacity)
            } else {
                MinimizedFoodItemView(foodItem: foodItem,
                                      textColor: textColor,
                                      subtextColor: subtextColor,
                                      backgroundColor: backgroundColor,
                                      isExpanded: $isExpanded)
                .transition(.opacity)
            }
        }
        .animation(.spring(), value: isExpanded)
    }
}


struct MinimizedFoodItemView: View {
    let foodItem: FoodItem
    var textColor: Color
    var subtextColor: Color
    var backgroundColor: Color
    @Binding var isExpanded: Bool
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        Button {
            withAnimation() {
                isExpanded = true
            }
        } label: {
            VStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack {
                        HStack {
                            Text(foodItem.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(textColor)
                            
                            Spacer()
                            
                            ServingSizeView(foodItem: foodItem)
                                .labelStyle(CustomLabel(spacing: 5))
                                .foregroundStyle(subtextColor)
                                .font(.footnote)
                        }
                        Line()
                            .frame(height: 1)
                            .background(.secondaryText)
                    }
                    
                    HStack {
                        let shownNutrients = min(3, foodItem.nutritionList.count)
                        HStack(spacing: 15) {
                            CalorieStatView(foodItem: foodItem)
                                .labelStyle(CustomLabel(spacing: 7))
                            ForEach(0..<shownNutrients, id: \.self) { index in
                                NutrientItemView(nutrientOfInterest: foodItem.nutritionList[index], foodItem: foodItem)
                                    .labelStyle(CustomLabel(spacing: 7))
                            }
                        }
                        .foregroundStyle(subtextColor)
                        .font(.footnote)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundStyle(textColor)
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
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondaryText, lineWidth: 0.5)
            )
            .cornerRadius(10)
        }
    }
}

struct ExpandedFoodItemView: View {
    
    let foodItem: FoodItem
    var textColor: Color
    var subtextColor: Color
    var backgroundColor: Color
    @Binding var isExpanded: Bool
    
    private func amPm(hour: Int) -> String {
        hour < 12 ? "AM" : "PM"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(foodItem.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    ServingSizeView(foodItem: foodItem, viewType: .txt)
                        .labelStyle(CustomLabel(spacing: 5))
                    
                    Text("Nutritional Information")
                        .fontWeight(.heavy)
                        .font(.subheadline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            CalorieStatView(foodItem: foodItem, viewType: .txt)
                                .fontWeight(.bold)
                            ForEach(foodItem.nutritionList) { nutrient in
                                NutrientItemView(nutrientOfInterest: nutrient, foodItem: foodItem, viewType: .txt)
                                    .fontWeight(.semibold)
                                ForEach(nutrient.childNutrients) { childNutrient in
                                    HStack {
                                        Image(systemName: "arrow.turn.down.right")
                                        NutrientItemView(nutrientOfInterest: childNutrient, foodItem: foodItem, viewType: .txt)
                                            .fontWeight(.light)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .foregroundStyle(subtextColor)
                .font(.footnote)
            }
            
            ZStack(alignment: .trailing) {
                Button {
                    withAnimation {
                        isExpanded = false
                    }
                } label: {
                    CloseButtonView()
                        .foregroundStyle(textColor)
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    // TODO: Fill out later when recipe editing becomes available
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(textColor)
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 10)
        .background(backgroundColor)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 10)
                .stroke(.secondaryText, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    FoodItemView(foodItem: MockData.foodItemList[0], backgroundColor: .backgroundColour)
    FoodItemView(foodItem: MockData.foodItemList[0], isExpanded: true, backgroundColor: .backgroundColour)
}
