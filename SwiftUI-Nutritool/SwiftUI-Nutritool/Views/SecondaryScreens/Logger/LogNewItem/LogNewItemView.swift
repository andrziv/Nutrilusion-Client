//
//  LogNewItemView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-28.
//

import SwiftUI

private enum LogItemViewMode: Identifiable {
    case showingRecipesView, creatingTransientRecipe
    
    var id: Int {
        switch self {
        case .showingRecipesView: return 1
        case .creatingTransientRecipe: return 2
        }
    }
}

struct LogNewItemView: View {
    @ObservedObject private var viewModel: NutriToolFoodViewModel
    @State private var draftLoggedMealItem: LoggedMealItem
    @State private var chosenFoodItem: FoodItem?
    
    private let exitWithoutComplete: () -> Void
    private let finalizeCreation: (LoggedMealItem) -> Void
    
    @State private var mode: LogItemViewMode?
    @State private var choosingNutrients: Bool
    
    init(viewModel: NutriToolFoodViewModel,
         date: Date, loggedMealItem: LoggedMealItem? = nil,
         exitWithoutComplete: @escaping () -> Void,
         finalizeCreation: @escaping (LoggedMealItem) -> Void) {
        self.viewModel = viewModel
        self.draftLoggedMealItem = loggedMealItem ?? LogNewItemView.generateLoggedMeal(with: date)
        self.chosenFoodItem = loggedMealItem?.meal
        
        self.exitWithoutComplete = exitWithoutComplete
        self.finalizeCreation = finalizeCreation
        
        self.mode = nil
        self.choosingNutrients = false
    }
    
    private static func generateLoggedMeal(with date: Date) -> LoggedMealItem {
        LoggedMealItem(date: date, meal: FoodItem(name: ""), emblemColour: Color.gray.toHex())
    }
    
    private func switchChosenFood(mealGroup: MealGroup?, foodItem: FoodItem) {
        chosenFoodItem = foodItem
        draftLoggedMealItem.meal = foodItem
        if let selectedGroup = mealGroup {
            draftLoggedMealItem.emblemColour = selectedGroup.colour
        }
        draftLoggedMealItem.importantNutrients = []
        self.mode = nil
    }
    
    var body: some View {
        VStack {
            VStack {
                LoggedMealPreviewView(draftLoggedMeal: draftLoggedMealItem, chosenFoodItem: chosenFoodItem)
                    .frame(maxHeight: 125)
                
                HStack {
                    FoodItemSelectionButtonSet(mode: $mode)
                    
                    LoggedMealEmblemColourPickerView(emblemColourHex: $draftLoggedMealItem.emblemColour)
                }
                
                LoggedFoodItemBuilderView(draftLoggedMeal: $draftLoggedMealItem, chosenFoodItem: $chosenFoodItem, choosingNutrients: $choosingNutrients)
            }
            .basicBackground(shadowRadius: 0, background: .secondaryComplement)
            
            LoggerActionButtonSet(draftLoggedMeal: draftLoggedMealItem,
                                  chosenFoodItem: chosenFoodItem,
                                  exitWithoutComplete: exitWithoutComplete,
                                  finalizeCreation: finalizeCreation)
        }
        .sheet(item: $mode) { mode in
            switch mode {
            case .showingRecipesView:
                RecipeListView(viewModel: viewModel) { mealGroup, foodItem in
                    switchChosenFood(mealGroup: mealGroup, foodItem: foodItem)
                }
                .onDisappear(perform: {
                    guard let existingFoodItem = chosenFoodItem else { return }
                    guard let potentiallyUpdatedItem = viewModel.foodByID[existingFoodItem.foodItemID] else { return }
                    guard existingFoodItem.version != potentiallyUpdatedItem.version else { return }
                    
                    switchChosenFood(mealGroup: nil, foodItem: potentiallyUpdatedItem)
                })
                
            case .creatingTransientRecipe:
                RecipeEditorView(foodItem: FoodItem(name: "", servingUnit: "", servingUnitMultiple: ""), viewModel: viewModel) {
                    self.mode = nil
                } onSaveAction: { selectedGroup, foodItem in
                    switchChosenFood(mealGroup: selectedGroup, foodItem: foodItem)
                }
            }
        }
    }
}

private struct LoggedMealPreviewView: View {
    let draftLoggedMeal: LoggedMealItem
    let chosenFoodItem: FoodItem?
    
    var body: some View {
        ZStack(alignment: .top) {
            let foodItem = chosenFoodItem ?? FoodItem(name: "Choose a Food Item!")
            
            let whiteness = Color.black.opacity(0.3)
            let animBackground = AnimatedBackgroundGradient(colours: [
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear
            ], radius: 0, cornerRadius: 7, isActive: true)
            
            let previewLoggedItem = LoggedMealItem(date: draftLoggedMeal.date,
                                                   meal: foodItem,
                                                   servingMultiple: draftLoggedMeal.servingMultiple,
                                                   importantNutrients: draftLoggedMeal.importantNutrients,
                                                   emblemColour: draftLoggedMeal.emblemColour)
            LoggedMealItemView(loggedItem: previewLoggedItem, backgroundView: animBackground)
                .padding()
            
            BottomTrailing {
                BreathingTextBoxView(text: "Preview", cornerRadius: 7)
            }
            
            StaticNoiseBox(cornerRadius: 7)
        }
    }
}

private struct FoodItemSelectionButtonSet: View {
    @Binding var mode: LogItemViewMode?
    
    var body: some View {
        ImagedButton(title: "Choose Recipes", icon: "text.badge.plus",
                     textFont: .callout.weight(.regular),
                     circleColour: .clear,
                     cornerRadius: 7,
                     verticalPadding: 6,
                     horizontalPadding: 6,
                     maxWidth: .infinity,
                     iconPlacement: .top) {
            mode = .showingRecipesView
        }
        
        ImagedButton(title: "Create Transient", icon: "plus.circle.dashed",
                     textFont: .callout.weight(.regular),
                     circleColour: .clear,
                     cornerRadius: 7,
                     verticalPadding: 6,
                     horizontalPadding: 6,
                     maxWidth: .infinity,
                     iconPlacement: .top) {
            mode = .creatingTransientRecipe
        }
    }
}

private struct LoggedMealEmblemColourPickerView: View {
    @Binding var emblemColourHex: String
    
    private func colourBinding() -> Binding<Color> {
        Binding<Color>(
            get: {
                Color(hex: emblemColourHex)
            },
            set: { newColor in
                emblemColourHex = newColor.toHex()
            }
        )
    }
    
    var body: some View {
        SquareColourPickerView(selection: colourBinding())
    }
}

private struct LoggedFoodItemBuilderView: View {
    @Binding var draftLoggedMeal: LoggedMealItem
    @Binding var chosenFoodItem: FoodItem?
    
    @Binding var choosingNutrients: Bool
    
    var body: some View {
        Group {
            let actionBackground = chosenFoodItem == nil ? .clear : Color.secondaryText.mix(with: .primaryComplement, by: 0.85)
            if !choosingNutrients {
                Group {
                    DateChooseView(selectedDate: $draftLoggedMeal.date)
                    
                    ServingSizeChangeView(servingMultiple: $draftLoggedMeal.servingMultiple,
                                          servingSize: chosenFoodItem?.servingAmount ?? 1,
                                          pluralUnit: chosenFoodItem?.servingUnitMultiple ?? "Servings",
                                          background: actionBackground)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
            
            ImportantNutrientChooseView(availableNutrients: chosenFoodItem?.nutritionList ?? [],
                                        selectedNutrients: $draftLoggedMeal.importantNutrients,
                                        isChoosingActive: $choosingNutrients,
                                        background: actionBackground)
        }
        .overlay(RoundedRectangle(cornerRadius: 7).fill(chosenFoodItem == nil ? .gray.opacity(0.08) : .clear))
        .disabled(chosenFoodItem == nil)
    }
}

private struct LoggerActionButtonSet: View {
    var loggedMealItem: LoggedMealItem
    var chosenFoodItem: FoodItem?
    
    let exitWithoutComplete: () -> Void
    let finalizeCreation: (LoggedMealItem) -> Void
    
    init(draftLoggedMeal: LoggedMealItem,
         chosenFoodItem: FoodItem?,
         exitWithoutComplete: @escaping () -> Void,
         finalizeCreation: @escaping (LoggedMealItem) -> Void) {
        self.loggedMealItem = draftLoggedMeal
        if let chosenFoodItem {
            self.loggedMealItem.meal = chosenFoodItem
        }
        self.chosenFoodItem = chosenFoodItem
        self.exitWithoutComplete = exitWithoutComplete
        self.finalizeCreation = finalizeCreation
    }
    
    var body: some View {
        HStack {
            ImagedButton(title: "Discard", icon: "xmark.circle.fill",
                         circleColour: .clear,
                         cornerRadius: 7,
                         maxWidth: .infinity,
                         backgroundColour: .secondaryComplement,
                         action: exitWithoutComplete)
            
            if chosenFoodItem != nil {
                ImagedButton(title: "Log", icon: "checkmark.circle.fill",
                             circleColour: .clear,
                             cornerRadius: 7,
                             maxWidth: .infinity,
                             backgroundColour: .secondaryComplement,
                             item: loggedMealItem,
                             action: finalizeCreation)
            }
        }
    }
}

private struct DateChooseView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        EditFieldView(title: "Log Date") {
            DatePicker("", selection: $selectedDate)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
}

private struct ServingSizeChangeView: View {
    @Binding var servingMultiple: Double
    let servingSize: Double
    let pluralUnit: String
    let background: Color
    
    private func servingBinding() -> Binding<Double> {
        Binding<Double>(
            get: {
                servingMultiple * servingSize
            },
            set: { newValue in
                servingMultiple = newValue / servingSize
            }
        )
    }
    
    var body: some View {
        EditFieldView(title: "Number of \(pluralUnit.capitalized)") {
            GranularValueTextField(topChangeValue: 1, interval: 0.5, value: servingBinding(), background: background)
        }
    }
}

private struct ImportantNutrientChooseView: View {
    let availableNutrients: [NutrientItem]
    @Binding var selectedNutrients: [NutrientItem]
    @Binding var isChoosingActive: Bool
    let background: Color
    
    @State private var isAtCapSelections: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("Max 3")
                .font(.footnote.bold())
                .foregroundStyle(.secondaryText)
                .zIndex(1)
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 6).fill(isAtCapSelections ? Color.red.opacity(0.25) : Color.secondaryText.mix(with: .primaryComplement, by: 0.85)))
                .padding(6)
            
            
            EditFieldView(title: "Display Nutrients") {
                if isChoosingActive {
                    NutrientCheckboxView(availableNutrients: availableNutrients, selectedNutrients: $selectedNutrients, isAtCapSelections: isAtCapSelections)
                        .scrollIndicators(.hidden)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)).animation(.easeInOut(duration: 0.15)))
                } else {
                    SelectedImportantNutrientView(availableNutrients: availableNutrients, selectedNutrients: $selectedNutrients)
                        .transition(.opacity.animation(.easeInOut(duration: 0.1)))
                }
                
                ImagedButton(title: isChoosingActive ? "Close" : "Choose Nutrients", icon: isChoosingActive ? "x.circle" : "plus.circle", imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular), circleColour: .clear, cornerRadius: 6, verticalPadding: 6, horizontalPadding: 6, maxWidth: .infinity, backgroundColour: background,iconPlacement: .leading) {
                    withAnimation {
                        isChoosingActive.toggle()
                    }
                }
            }
            .onChange(of: selectedNutrients) {
                isAtCapSelections = selectedNutrients.count >= 3
            }
        }
    }
}

private struct SelectedImportantNutrientView: View {
    let availableNutrients: [NutrientItem]
    @Binding var selectedNutrients: [NutrientItem]
    
    private func extraInformation() -> (String, Color) {
        if availableNutrients.count == selectedNutrients.count {
            return ("", .clear)
        }
        if selectedNutrients.isEmpty {
            return ("Empty! Add Some Nutrients.", .secondaryComplement)
        } else if selectedNutrients.count < 3 {
            return ("Still Space Left", .secondaryComplement)
        }
        
        return ("", .clear)
    }
    
    var body: some View {
        NutrientChipView(selectedNutrients: $selectedNutrients)
        
        let extraInfo = extraInformation()
        
        Rectangle()
            .fill(.clear)
            .overlay{
                RoundedRectangle(cornerRadius: 7)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundStyle(extraInfo.1)
                    .overlay(Text(extraInfo.0).foregroundStyle(extraInfo.1))
            }
    }
}

private struct EditFieldView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title).fontWeight(.semibold)
            content
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 7).fill(.primaryComplement))
    }
}


#Preview {
    LogNewItemView(viewModel: NutriToolFoodViewModel(repository: MockFoodRepository()), date: Date()) {
        
    } finalizeCreation: { loggedItem in
        
    }
}
