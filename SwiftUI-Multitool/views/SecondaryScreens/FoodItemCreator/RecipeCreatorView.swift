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
    @State var foodItem: FoodItem
    @State private var titleInput: String
    @State private var unitSingularInput: String
    @State private var unitPluralInput: String
    @State private var selectedMode: RecipeCreatorMode
    
    init(foodItem: FoodItem) {
        self.foodItem = foodItem
        self.titleInput = foodItem.name
        self.unitSingularInput = foodItem.servingUnit
        self.unitPluralInput = foodItem.servingUnitMultiple
        self.selectedMode = .manual
    }
    
    var body: some View {
        VStack {
            HStack {
                FoodItemNameUnitFieldSet(titleInput: $titleInput,
                                         unitSingularInput: $unitSingularInput,
                                         unitPluralInput: $unitPluralInput)
                
                ModeSwitcherView(selectedMode: $selectedMode)
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
        .basicBackground()
    }
}

private struct FoodItemNameUnitFieldSet: View {
    @Binding var titleInput: String
    @Binding var unitSingularInput: String
    @Binding var unitPluralInput: String
    
    var body: some View {
        VStack {
            UnderlineTextField(textBinding: $titleInput, placeholder: "Name of the Recipe", borderColour: titleInput.isEmpty ? .red : .green, backgroundColour: Color.gray.opacity(0.1))
                .disableAutocorrection(true)
            
            HStack {
                UnderlineTextField(textBinding: $unitSingularInput, placeholder: "Unit Name", borderColour: unitSingularInput.isEmpty ? .red : .green, backgroundColour: Color.gray.opacity(0.1))
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                
                UnderlineTextField(textBinding: $unitPluralInput, placeholder: "Plural Unit", borderColour: unitPluralInput.isEmpty ? .red : .green, backgroundColour: Color.gray.opacity(0.1))
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
        }
    }
}

private struct ModeSwitcherView: View {
    @Binding var selectedMode: RecipeCreatorMode
    
    var body: some View {
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
                                         background: Color.gray.opacity(0.1))
                }
            }
        }
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

#Preview {
    RecipeCreatorView(foodItem: MockData.sampleFoodItem)
}
