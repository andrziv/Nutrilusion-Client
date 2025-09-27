//
//  RecipeEditorView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

fileprivate enum RecipeEditorMode: Int, CaseIterable {
    case nutrient = 0
    case ingredient
    case camera
    
    var title: String {
        switch self {
        case .nutrient:
            return "Nutrient"
        case .ingredient:
            return "Ingredient"
        case .camera:
            return "Camera"
        }
    }
    
    var position: Position {
        switch self {
        case .nutrient:
            return Position.topmid
        case .ingredient:
            return Position.mid
        case .camera:
            return Position.botmid
        }
    }
}

struct RecipeEditorView: View {
    let foodItem: FoodItem
    @ObservedObject var viewModel: NutriToolFoodViewModel
    
    let onExitAction: () -> Void
    let onSaveAction: (MealGroup?, FoodItem) -> Void
    
    @State private var draftFoodItem: FoodItem
    @State private var selectedMealGroup: MealGroup?
    @State private var selectedMode: RecipeEditorMode
    
    init(foodItem: FoodItem, viewModel: NutriToolFoodViewModel,
         onExitAction: @escaping () -> Void, onSaveAction: @escaping (MealGroup?, FoodItem) -> Void) {
        self.foodItem = foodItem
        self.viewModel = viewModel
        self.onExitAction = onExitAction
        self.onSaveAction = onSaveAction
        
        self._draftFoodItem = State(initialValue: foodItem)
        self._selectedMealGroup = State(initialValue:
            viewModel.mealGroups.first { group in
                group.foodIDs.contains(foodItem.foodItemID)
            } ?? viewModel.mealGroups.first
        )
        self._selectedMode = State(initialValue: .ingredient)
    }
    
    var body: some View {
        VStack {
            HStack {
                let bgColourHex = selectedMealGroup?.colour ?? Color("backgroundColour").mix(with: .primaryText, by: 0.3).toHex()!
                let backgroundColour = Color(hex: bgColourHex)
                FoodItemBasicInfoEditors(titleInput: $draftFoodItem.name,
                                         unitSingularInput: $draftFoodItem.servingUnit,
                                         unitPluralInput: $draftFoodItem.servingUnitMultiple,
                                         selectedGroup: $selectedMealGroup,
                                         availableMealGroups: viewModel.mealGroups)
                .padding(5)
                .background(Rectangle().fill(backgroundColour).blur(radius: 200))
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
                
                ModeSwitcherView(selectedMode: $selectedMode)
                    .frame(maxWidth: 80)
            }
            
            ContentView(foodItem: $draftFoodItem, viewModel: viewModel, mode: selectedMode)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(.secondaryBackground))
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, iconPlacement: .trailing, action: onExitAction)
                
                ImagedButton(title: "Save & Exit", icon: "tray.and.arrow.down.fill", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, iconPlacement: .leading,
                             item: (selectedMealGroup, draftFoodItem), action: onSaveAction)
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
    @Binding var selectedGroup: MealGroup?
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
            
            if let selectionBinding = Binding<MealGroup>($selectedGroup), !availableMealGroups.isEmpty {
                FoodGroupPicker(mealgroups: availableMealGroups, selectedGroup: selectionBinding)
            } else {
                HStack {
                    Spacer()
                    
                    Text("No Categories Available")
                    
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
    @Binding var selectedMode: RecipeEditorMode
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(RecipeEditorMode.allCases, id: \.self) { item in
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
    let viewModel: NutriToolFoodViewModel
    var mode: RecipeEditorMode
    
    var body: some View {
        switch mode {
        case .nutrient:
            NutrientEditorModeView(foodItem: $foodItem)
        case .ingredient:
            IngredientEditorModeView(draftFoodItem: $foodItem, viewModel: viewModel)
        case .camera:
            CameraImporterModeView(foodItem: $foodItem)
        }
    }
}

#Preview {
    let viewModel = NutriToolFoodViewModel(repository: MockFoodRepository())
    RecipeEditorView(foodItem: MockData.sampleFoodItem, viewModel: viewModel) {
        
    } onSaveAction: { selectedGroup, foodItem in
        
    }
}
