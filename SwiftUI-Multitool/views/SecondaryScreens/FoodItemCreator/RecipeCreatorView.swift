//
//  RecipeCreatorView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

fileprivate enum RecipeCreatorMode: Int, CaseIterable {
    case manual = 0
    case builder
    case camera
    
    var title: String {
        switch self {
        case .manual:
            return "Manual"
        case .builder:
            return "Builder"
        case .camera:
            return "Camera"
        }
    }
    
    var position: Position {
        switch self {
        case .manual:
            return Position.topmid
        case .builder:
            return Position.mid
        case .camera:
            return Position.botmid
        }
    }
}

struct RecipeCreatorView: View {
    @State var foodItem: FoodItem = .init(id: UUID(), name: "", calories: 0)
    @State private var title: String = ""
    @State private var selectedMode: RecipeCreatorMode = .manual
    
    var body: some View {
        VStack {
            HStack {
                BasicTextField(textBinding: $title, placeholder: "Name of the Recipe")
                
                VStack(spacing: 0) {
                    ForEach(RecipeCreatorMode.allCases, id: \.self) { item in
                        Button {
                            withAnimation(.snappy) {
                                selectedMode = item
                            }
                        } label: {
                            PositionalButtonView(mainText: item.title,
                                                 position: item.position,
                                                 isSelected: selectedMode == item,
                                                 background: .regularMaterial)
                        }
                    }
                }
                .frame(maxWidth: 80)
            }
            
            ContentView(foodItem: $foodItem, mode: selectedMode)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColor: .clear, cornerRadius: 10) {
                    
                }
                
                ImagedButton(title: "Save & Exit", icon: "tray.and.arrow.down.fill", circleColor: .clear, cornerRadius: 10) {
                    
                }
            }
        }
        .padding()
    }
}

private struct ContentView: View {
    @Binding var foodItem: FoodItem
    var mode: RecipeCreatorMode
    
    var body: some View {
        switch mode {
        case .manual:
            ManualCreatorModeView(foodItem: $foodItem)
        case .builder:
            BuilderCreatorModeView(foodItem: $foodItem)
        case .camera:
            CameraCreatorModeView(foodItem: $foodItem)
        }
    }
}

struct ManualCreatorModeView: View {
    @Binding var foodItem: FoodItem
    @State private var showNutritionList: Bool = false
    
    var body: some View {
        VStack {
            CalorieStatView(foodItem: foodItem,
                            viewType: .txt,
                            primaryTextColor: .primaryText)
            .labelStyle(CustomLabel(spacing: 7))
            .font(.callout)
            .fontWeight(.bold)
            
            ForEach(foodItem.nutritionList) { nutrient in
                NutrientItemView(nutrientOfInterest: nutrient,
                                 viewType: .txt,
                                 primaryTextColor: .primaryText)
                .fontWeight(.semibold)
                
                ForEach(nutrient.childNutrients) { childNutrient in
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                        NutrientItemView(nutrientOfInterest: childNutrient, viewType: .txt)
                            .fontWeight(.light)
                    }
                }
            }
            .font(.footnote)
            .labelStyle(CustomLabel(spacing: 7))
            
            Button {
                showNutritionList = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.backgroundColour.mix(with: .primaryText, by: 0.1)))
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8, 10]))
                            .foregroundStyle(.primaryText.mix(with: .backgroundColour, by: 0.5))
                    }
            }
        }
        .fullScreenCover(isPresented: $showNutritionList) {
            NutrientAdderPopup(isActive: $showNutritionList, foodItem: $foodItem)
        }
    }
}

struct BuilderCreatorModeView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        VStack {
            Text("Builder Mode")
        }
    }
}

struct CameraCreatorModeView: View {
    @Binding var foodItem: FoodItem
    
    var body: some View {
        VStack {
            Text("Camera Mode")
        }
    }
}

#Preview {
    RecipeCreatorView()
}
