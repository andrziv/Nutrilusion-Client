//
//  RecipeCreatorView.swift
//  SwiftUI-Nutritool
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
    let foodItem: FoodItem
    let mealGroups: [MealGroup]
    let onExitAction: () -> Void
    let onSaveAction: (MealGroup, FoodItem) -> Void
    
    @State private var draftFoodItem: FoodItem
    @State private var selectedMealGroup: MealGroup
    @State private var selectedMode: RecipeCreatorMode
    
    init(foodItem: FoodItem, mealGroups: [MealGroup], onExitAction: @escaping () -> Void, onSaveAction: @escaping (MealGroup, FoodItem) -> Void) {
        self.foodItem = foodItem
        self.mealGroups = mealGroups
        self.onExitAction = onExitAction
        self.onSaveAction = onSaveAction
        
        self.draftFoodItem = foodItem
        self.selectedMealGroup = mealGroups.first { group in
            group.meals.contains { $0.id == foodItem.id }
        } ?? mealGroups[0]
        self.selectedMode = .builder
    }
    
    var body: some View {
        VStack {
            HStack {
                FoodItemBasicInfoEditors(titleInput: $draftFoodItem.name,
                                         unitSingularInput: $draftFoodItem.servingUnit,
                                         unitPluralInput: $draftFoodItem.servingUnitMultiple,
                                         selectedGroup: $selectedMealGroup,
                                         availableMealGroups: mealGroups)
                .padding(5)
                .background(Rectangle().fill(Color(hex: selectedMealGroup.colour)).blur(radius: 200))
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
                
                ModeSwitcherView(selectedMode: $selectedMode)
                    .frame(maxWidth: 80)
            }
            
            ContentView(foodItem: $draftFoodItem, mealGroupList: mealGroups, mode: selectedMode)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.secondaryBackground))
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, action: onExitAction)
                
                ImagedButton(title: "Save & Exit", icon: "tray.and.arrow.down.fill", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, action: onSaveAction, item: (selectedMealGroup, draftFoodItem))
            }
            
            Spacer()
        }
        .basicBackground()
    }
}

private struct FoodItemBasicInfoEditors: View {
    @Binding var titleInput: String
    @Binding var unitSingularInput: String
    @Binding var unitPluralInput: String
    @Binding var selectedGroup: MealGroup
    var availableMealGroups: [MealGroup]
    
    var body: some View {
        VStack(spacing: 5) {
            let emptyInputColour: Color = .red.mix(with: .secondaryBackground, by: 0.8)
            
            BasicTextField("Name of the Recipe", text: $titleInput,
                           cornerRadius: 7, outlineWidth: 0,
                           background: unitSingularInput.isEmpty ? emptyInputColour : .secondaryBackground.opacity(0.45),
                           horizontalPadding: 8,
                           verticalPadding: 4)
            .disableAutocorrection(true)
            
            HStack(spacing: 5) {
                BasicTextField("Unit Name", text: $unitSingularInput,
                               cornerRadius: 7, outlineWidth: 0,
                               background: unitSingularInput.isEmpty ? emptyInputColour : .secondaryBackground.opacity(0.45),
                               horizontalPadding: 8,
                               verticalPadding: 5)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                
                BasicTextField("Plural Unit", text: $unitPluralInput,
                               cornerRadius: 7, outlineWidth: 0,
                               background: unitPluralInput.isEmpty ? emptyInputColour : .secondaryBackground.opacity(0.45),
                               horizontalPadding: 8,
                               verticalPadding: 5)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            }
            
            FoodGroupPicker(mealgroups: availableMealGroups, selectedGroup: $selectedGroup)
        }
    }
}

struct FoodGroupPicker: View {
    let mealgroups: [MealGroup]
    @Binding var selectedGroup: MealGroup
    
    var body: some View {
        Menu {
            ForEach(mealgroups) { mealGroup in
                Button() {
                    selectedGroup = mealGroup
                } label: {
                    Text("\(mealGroup.name)")
                    if selectedGroup.id == mealGroup.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Spacer()
                
                Text("\(selectedGroup.name)")
                    .font(.callout.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2)
                
                Spacer()
            }
            .foregroundStyle(.primaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(.secondaryBackground.opacity(0.45))
            )
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
                                         cornerRadius: 10,
                                         background: .secondaryBackground,
                                         mainFontWeight: .medium,
                                         mainFontWeightSelected: .bold)
                }
            }
        }
    }
}

private struct ContentView: View {
    @Binding var foodItem: FoodItem
    let mealGroupList: [MealGroup]
    var mode: RecipeCreatorMode
    
    var body: some View {
        switch mode {
        case .manual:
            ManualCreatorModeView(foodItem: $foodItem)
        case .builder:
            BuilderCreatorModeView(foodItem: $foodItem, mealGroups: mealGroupList)
        case .camera:
            CameraCreatorModeView(foodItem: $foodItem)
        }
    }
}

#Preview {
    RecipeCreatorView(foodItem: MockData.sampleFoodItem, mealGroups: MockData.mealGroupList) {
        
    } onSaveAction: { selectedGroup, foodItem in
        
    }
}
