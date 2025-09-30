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
    
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @State var logDate: Date
    @State private var chosenFoodItem: FoodItem? = nil
    @State private var importantNutrients: [NutrientItem] = []
    @State private var servingsLogged: Double = 1
    @State private var colour: Color = .gray
    
    @State private var mode: LogItemViewMode? = nil
    @State private var choosingNutrients: Bool = false
    
    let exitWithoutComplete: () -> Void
    let finalizeCreation: (LoggedMealItem) -> Void
    
    private func switchChosenFood(mealGroup: MealGroup?, foodItem: FoodItem) {
        chosenFoodItem = foodItem
        if let selectedGroup = mealGroup {
            colour = Color(hex: selectedGroup.colour)
        }
        importantNutrients = []
        self.mode = nil
    }
    
    var body: some View {
        VStack {
            VStack {
                LoggedMealPreviewView(chosenFoodItem: chosenFoodItem,
                                      logDate: logDate,
                                      servingSize: servingsLogged,
                                      importantNutrients: importantNutrients,
                                      colourPicked: colour)
                .frame(maxHeight: 125)
                
                HStack {
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
                    
                    SquareColourPickerView(selection: $colour)
                }

                VStack {
                    Group {
                        let actionBackground = chosenFoodItem == nil ? .clear : Color.secondaryText.mix(with: .primaryComplement, by: 0.85)
                        if !choosingNutrients {
                            Group {
                                DateChooseView(selectedDate: $logDate)
                                
                                ServingSizeChangeView(servingSize: $servingsLogged, background: actionBackground)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        }
                        
                        ImportantNutrientChooseView(availableNutrients: chosenFoodItem?.nutritionList ?? [], selectedNutrients: $importantNutrients, isChoosingActive: $choosingNutrients, background: actionBackground)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 7).fill(chosenFoodItem == nil ? .gray.opacity(0.08) : .clear))
                    .disabled(chosenFoodItem == nil)
                }
            }
            .basicBackground(shadowRadius: 0, background: .secondaryComplement)
            
            HStack {
                ImagedButton(title: "Discard", icon: "xmark.circle.fill", cornerRadius: 7, maxWidth: .infinity, backgroundColour: .secondaryComplement, action: exitWithoutComplete)

                if let chosenFoodItem = chosenFoodItem {
                    ImagedButton(title: "Log", icon: "checkmark.circle.fill", cornerRadius: 7, maxWidth: .infinity, backgroundColour: .secondaryComplement,
                                 item: LoggedMealItem(date: logDate, meal: chosenFoodItem, servingMultiple: servingsLogged, importantNutrients: importantNutrients, emblemColour: colour), action: finalizeCreation)
                }
            }
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
                RecipeEditorView(foodItem: FoodItem(name: ""), viewModel: viewModel) {
                    self.mode = nil
                } onSaveAction: { selectedGroup, foodItem in
                    switchChosenFood(mealGroup: selectedGroup, foodItem: foodItem)
                }
            }
        }
    }
}

private struct LoggedMealPreviewView: View {
    let chosenFoodItem: FoodItem?
    let logDate: Date
    let servingSize: Double
    let importantNutrients: [NutrientItem]
    let colourPicked: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            let foodItem = chosenFoodItem ?? FoodItem(name: "Choose a Food Item!")
            
            let whiteness = Color.black.opacity(0.3)
            let animBackground = AnimatedBackgroundGradient(colours: [
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear,
                whiteness, whiteness, whiteness, .clear
            ], radius: 0, cornerRadius: 7, isActive: .constant(true))
            
            let previewLoggedItem = LoggedMealItem(date: logDate,
                                                   meal: foodItem,
                                                   servingMultiple: servingSize,
                                                   importantNutrients: importantNutrients,
                                                   emblemColour: colourPicked)
            LoggedMealItemView(loggedItem: previewLoggedItem, backgroundView: animBackground)
                .padding()
            
            BottomTrailing {
                BreathingTextBoxView(text: "Preview", cornerRadius: 7)
            }
            
            StaticNoiseBox(cornerRadius: 7)
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
    @Binding var servingSize: Double
    let background: Color
    
    var body: some View {
        EditFieldView(title: "Servings") {
            GranularValueTextField(topChangeValue: 1, interval: 0.5, value: $servingSize, actionBackgroundColour: background)
        }
    }
}

private struct ImportantNutrientChooseView: View {
    let availableNutrients: [NutrientItem]
    @Binding var selectedNutrients: [NutrientItem]
    @Binding var isChoosingActive: Bool
    let background: Color
    
    @State private var isAtCapSelections: Bool = false
    
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
                    NutrientChipView(selectedNutrients: $selectedNutrients)
                        .transition(.opacity.animation(.easeInOut(duration: 0.1)))
                    
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

private struct GranularValueTextField: View {
    var topChangeValue: Double = 1
    var interval: Double = 0.5
    @Binding var value: Double
    var actionBackgroundColour: Color = .gray
    
    var body: some View {
        HStack(spacing: 4) {
            ImagedButton(title: "1", icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: actionBackgroundColour,
                         iconPlacement: .leading) {
                value = Swift.max(0, value - topChangeValue)
            }
            ImagedButton(title: "0.5", icon: "minus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: actionBackgroundColour,
                         iconPlacement: .leading) {
                value = Swift.max(0, value - topChangeValue + interval)
            }
            
            BasicTextField("", value: $value, format: .number,
                           font: .subheadline,
                           fontWeight: .regular,
                           cornerRadius: 7,
                           outline: .clear, outlineWidth: 0,
                           background: actionBackgroundColour,
                           horizontalPadding: 6,
                           verticalPadding: 6)
            .multilineTextAlignment(.center)
            
            ImagedButton(title: "0.5", icon: "plus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: actionBackgroundColour,
                         iconPlacement: .leading) {
                value += topChangeValue - interval
            }
            ImagedButton(title: "1", icon: "plus",
                         imageFont: .subheadline.weight(.regular), textFont: .subheadline.weight(.regular),
                         circleColour: .clear,
                         cornerRadius: 7,
                         verticalPadding: 6,
                         horizontalPadding: 6,
                         backgroundColour: actionBackgroundColour,
                         iconPlacement: .leading) {
                value += topChangeValue
            }
        }
    }
}


#Preview {
    LogNewItemView(viewModel: NutriToolFoodViewModel(repository: MockFoodRepository()), logDate: Date()) {
        
    } finalizeCreation: { loggedItem in
        
    }
}
