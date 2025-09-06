//
//  AddCategoryPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct AddCategoryPopupView: View {
    @Binding var screenMode: RecipeListViewMode?
    @Binding var mealGroups: [MealGroup]
    
    @State private var searchString: String = ""
    @State private var colourPicked: Color = .blue
    
    var body: some View {
        VStack(spacing: 5) {
            MealGroupPreviewView(searchString: $searchString, colourPicked: $colourPicked)
                .background(RoundedRectangle(cornerRadius: 10).fill(.backgroundColour))
            
            Spacer()
            
            HStack {
                BasicTextField("Group name... eg: Breakfast", text: $searchString, outline: colourPicked)
                
                SquareColourPickerView(selection: $colourPicked)
            }
            
            Spacer()
            
            HStack {
                ImagedButton(title: "Dismiss", icon: "xmark", circleColour: .clear, cornerRadius: 10) {
                    screenMode = nil
                }
                
                ImagedButton(title: "Create Category", icon: "plus", circleColour: .clear, cornerRadius: 10, maxWidth: .infinity) {
                    // TODO: Change this to use CoreData later...
                    mealGroups.append(MealGroup(id: UUID(uuidString: "10000000-0000-0000-0000-000000000000")!, name: searchString, meals: [], colour: colourPicked.toHex()!))
                    screenMode = nil
                }
            }
            
            Spacer(minLength: 5)
        }
        .basicBackground()
    }
}

struct MealGroupPreviewView: View {
    @Binding var searchString: String
    @Binding var colourPicked: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            MealGroupView(group: MealGroup(id: UUID(), name: searchString, meals: [MockData.sampleFoodItem], colour: colourPicked.toHex()!))
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
    AddCategoryPopupView(screenMode: .constant(.addCategory), mealGroups: .constant(MockData.mealGroupList))
}
