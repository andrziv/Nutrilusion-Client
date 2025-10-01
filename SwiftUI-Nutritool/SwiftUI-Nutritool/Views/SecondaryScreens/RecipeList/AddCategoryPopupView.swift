//
//  AddCategoryPopupView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct AddCategoryPopupView: View {
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @Binding var screenMode: RecipeListViewMode?
    
    let creationAction: (MealGroup) -> Void
    
    @State private var titleString: String = ""
    @State private var colourPicked: Color = .blue
    
    var body: some View {
        VStack(spacing: 5) {
            MealGroupPreviewView(titleString: $titleString, colourPicked: $colourPicked)
                .background(RoundedRectangle(cornerRadius: 10).fill(.backgroundColour))
            
            HStack {
                BasicTextField("Group name... eg: Breakfast", text: $titleString, outline: colourPicked)
                
                SquareColourPickerView(selection: $colourPicked)
            }
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, iconPlacement: .trailing) {
                    screenMode = nil
                }
                
                ImagedButton(title: "Create Category", icon: "plus", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, iconPlacement: .leading) {
                    creationAction(MealGroup(id: UUID(), name: titleString, foodIDs: [], colour: colourPicked.toHex()))
                    screenMode = nil
                }
            }
            
            Spacer(minLength: 5)
        }
        .basicBackground()
    }
}

struct MealGroupPreviewView: View {
    @Binding var titleString: String
    @Binding var colourPicked: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            let previewFoodItem = MockData.sampleFoodItem
            let previewGroup = MealGroup(id: UUID(), name: titleString, foodIDs: [previewFoodItem.foodItemID], colour: colourPicked.toHex())
            MealGroupView(viewModel: NutriToolFoodViewModel(repository: MockFoodRepository(foods: [previewFoodItem], mealGroups: [previewGroup])),
                          group: previewGroup)
            .id(titleString + (colourPicked.toHex()))
            .padding(.vertical)
            
            BottomTrailing {
                BreathingTextBoxView(text: "Preview")
            }
            
            StaticNoiseBox()
        }
    }
}

#Preview {
    let viewModel = NutriToolFoodViewModel(repository: MockFoodRepository())
    AddCategoryPopupView(viewModel: viewModel, screenMode: .constant(.addCategory)) { newMealGroup in
        
    }
}
