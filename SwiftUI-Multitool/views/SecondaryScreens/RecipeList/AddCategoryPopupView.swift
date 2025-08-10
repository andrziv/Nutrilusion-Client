//
//  AddCategoryPopupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-09.
//


import SwiftUI

struct AddCategoryPopupView: View {
    @Binding var screenMode: RecipeListViewMode
    @Binding var mealGroups: [MealGroup]
    
    @State private var searchString: String = ""
    @State private var colourPicked: Color = .blue
    
    var body: some View {
        VStack {
            MealGroupPreviewView(searchString: $searchString, colourPicked: $colourPicked)
                .background(RoundedRectangle(cornerRadius: 10).fill(.white))
                .frame(maxHeight: 500)
            
            Spacer()
            
            HStack {
                BasicTextField(textBinding: $searchString, placeholder: "Group name... eg: Breakfast", outline: colourPicked)
                
                SquareColourPickerView(selection: $colourPicked)
            }
            
            Spacer()
            
            HStack {
                ImagedButton(title: "Dismiss", icon: "xmark", circleColor: .clear, cornerRadius: 10) {
                    screenMode = .normal
                }
                
                ImagedButton(title: "Create Category", icon: "plus", circleColor: .clear, cornerRadius: 10) {
                    // TODO: Change this to use CoreData later...
                    mealGroups.append(MealGroup(name: searchString, meals: [], colour: colourPicked.toHex()!))
                    screenMode = .normal
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
            MealGroupView(group: MealGroup(name: searchString, meals: [MockData.sampleFoodItem], colour: colourPicked.toHex()!))
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
