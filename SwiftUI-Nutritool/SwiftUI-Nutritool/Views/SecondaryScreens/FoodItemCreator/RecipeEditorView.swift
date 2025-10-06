//
//  RecipeEditorView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

fileprivate enum RecipeEditorMode: Int, CaseIterable {
    case ingredient = 0
    case nutrient
    case camera
    
    var title: String {
        switch self {
        case .nutrient:
            return "Nutrients"
        case .ingredient:
            return "Ingredients"
        case .camera:
            return "Camera"
        }
    }
    
    var position: Position {
        switch self {
        case .nutrient:
            return Position.right
        case .ingredient:
            return Position.left
        case .camera:
            return Position.isolated
        }
    }
    
    var leftPadding: CGFloat {
        switch self {
        case .nutrient:
            return 0
        case .ingredient:
            return 0
        case .camera:
            return 7.5
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
        
        self.draftFoodItem = foodItem
        self.selectedMealGroup = viewModel.mealGroups.first { group in
            group.foodIDs.contains(foodItem.foodItemID)
        } ?? viewModel.mealGroups.first
        self.selectedMode = .ingredient
    }
    
    var body: some View {
        let bgColourHex = selectedMealGroup?.colour ?? Color("backgroundColour").mix(with: .primaryText, by: 0.3).toHex()
        let backgroundColour = Color(hex: bgColourHex).opacity(0.3)
        VStack {
            HStack {
                GroupInfoEditor(selectedGroup: $selectedMealGroup, availableMealGroups: viewModel.mealGroups)
                
                ImagedButton(title: nil, icon: "xmark", circleColour: .clear, cornerRadius: 7, iconPlacement: .trailing, action: onExitAction)
                
                ImagedButton(title: nil, icon: "tray.and.arrow.down.fill", imageFont: .system(size: 10), circleColour: .clear, cornerRadius: 7, iconPlacement: .leading,
                             item: (selectedMealGroup, draftFoodItem), action: onSaveAction)
            }
            
            FoodItemBasicInfoEditors(titleInput: $draftFoodItem.name,
                                     unitSingularInput: $draftFoodItem.servingUnit,
                                     unitPluralInput: $draftFoodItem.servingUnitMultiple)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 7).fill(.primaryComplement))
            
            ContentView(foodItem: $draftFoodItem, viewModel: viewModel, mode: selectedMode)
                .background(RoundedRectangle(cornerRadius: 7).fill(.primaryComplement))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            
            ModeSwitcherView(selectedMode: $selectedMode)
            
            Spacer()
        }
        .basicBackground(shadowRadius: 0,
                         background: LinearGradient(colors: [backgroundColour, .backgroundColour, .backgroundColour, .backgroundColour], startPoint: .top, endPoint: .bottom))
    }
}

private struct FoodItemBasicInfoEditors: View {
    @Binding var titleInput: String
    @Binding var unitSingularInput: String
    @Binding var unitPluralInput: String
    
    var body: some View {
        VStack(spacing: 5) {
            let emptyInputColour: Color = .red.mix(with: .primaryComplement, by: 0.7)
            
            BasicInfoEditorView(placeholder: "Name of the Recipe", text: $titleInput, font: .title3, emptyColour: emptyInputColour)
                .disableAutocorrection(true)
            
            HStack(spacing: 5) {
                BasicInfoEditorView(placeholder: "Unit Name", text: $unitSingularInput, font: .headline, emptyColour: emptyInputColour)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                
                Image(systemName: "arrow.left.and.right")
                
                BasicInfoEditorView(placeholder: "Plural Unit", text: $unitPluralInput, font: .headline, emptyColour: emptyInputColour)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
        }
        
    }
}

private struct BasicInfoEditorView: View {
    let placeholder: String
    @Binding var text: String
    let font: Font
    let emptyColour: Color
    
    var body: some View {
        BasicTextField(placeholder, text: $text,
                       font: font, fontWeight: .semibold,
                       cornerRadius: 4, outline: .secondaryText, outlineWidth: 0,
                       background: text.isEmpty ? emptyColour : .clear,
                       horizontalPadding: 6,
                       verticalPadding: 3)
        .multilineTextAlignment(.center)
    }
}

private struct GroupInfoEditor: View {
    @Binding var selectedGroup: MealGroup?
    var availableMealGroups: [MealGroup]
    
    var body: some View {
        Group {
            if let selectionBinding = Binding<MealGroup>($selectedGroup), !availableMealGroups.isEmpty {
                FoodGroupPicker(mealgroups: availableMealGroups, selectedGroup: selectionBinding)
            } else {
                HStack {
                    Spacer()
                    
                    Text("No Categories Available")
                    
                    Spacer()
                }
            }
        }
        .foregroundStyle(.primaryText)
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(.primaryComplement)
        )
    }
}

private struct FoodGroupPicker: View {
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
        }
    }
}


private struct ModeSwitcherView: View {
    @Binding var selectedMode: RecipeEditorMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(RecipeEditorMode.allCases, id: \.self) { item in
                Button {
                    withAnimation(.snappy) {
                        selectedMode = item
                    }
                } label: {
                    PositionalButtonView(mainText: item.title,
                                         position: item.position,
                                         isSelected: selectedMode == item,
                                         cornerRadius: 7,
                                         background: .primaryComplement,
                                         mainFontWeight: .medium,
                                         mainFontWeightSelected: .bold)
                    .padding(.leading, item.leftPadding)
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
                .padding(10)
        case .ingredient:
            IngredientEditorModeView(draftFoodItem: $foodItem, viewModel: viewModel)
                .padding(10)
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
