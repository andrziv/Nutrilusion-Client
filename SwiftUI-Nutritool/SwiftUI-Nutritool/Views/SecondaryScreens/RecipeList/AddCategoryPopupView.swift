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
    
    @State private var searchString: String = ""
    @State private var colourPicked: Color = .blue
    
    var body: some View {
        VStack(spacing: 5) {
            MealGroupPreviewView(viewModel: viewModel, searchString: $searchString, colourPicked: $colourPicked)
                .background(RoundedRectangle(cornerRadius: 10).fill(.backgroundColour))
            
            Spacer()
            
            HStack {
                BasicTextField("Group name... eg: Breakfast", text: $searchString, outline: colourPicked)
                
                SquareColourPickerView(selection: $colourPicked)
            }
            
            Spacer()
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColour: .clear, cornerRadius: 10, iconPlacement: .trailing) {
                    screenMode = nil
                }
                
                ImagedButton(title: "Create Category", icon: "plus", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity, iconPlacement: .leading) {
                    creationAction(MealGroup(id: UUID(), name: searchString, foodIDs: [], colour: colourPicked.toHex()!))
                    screenMode = nil
                }
            }
            
            Spacer(minLength: 5)
        }
        .basicBackground()
    }
}

struct MealGroupPreviewView: View {
    @ObservedObject var viewModel: NutriToolFoodViewModel
    @Binding var searchString: String
    @Binding var colourPicked: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            MealGroupView(viewModel: viewModel,
                          group: MealGroup(id: UUID(),
                                           name: searchString,
                                           foodIDs: [MockData.sampleFoodItem.foodItemID],
                                           colour: colourPicked.toHex()!))
            .id(searchString + (colourPicked.toHex() ?? ""))
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
