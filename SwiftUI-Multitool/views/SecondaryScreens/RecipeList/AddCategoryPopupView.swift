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
            ZStack(alignment: .top) {
                MealGroupView(group: MealGroup(name: searchString, meals: [MockData.sampleFoodItem], colour: colourPicked.toHex()!))
                    .id(searchString + (colourPicked.toHex() ?? ""))
                    .padding(.vertical)
                
                BottomTrailing {
                    Text("Preview")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .opacity(0.2))
                        .padding(4)
                }
                .phaseAnimator([1.0, 0]) { content, phase in
                    content.opacity(phase)
                } animation: { _ in
                        .easeInOut(duration: 5.0)
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .randomNoiseShader()
                    .opacity(0.1)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(.clear, lineWidth: 1))
                
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .frame(maxHeight: 500)
            
            Spacer()
            
            BasicTextField(textBinding: $searchString, placeholder: "Group name... eg: Breakfast", outline: colourPicked)
            
            ColorPicker("Colour of the Group Header", selection: $colourPicked)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
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

#Preview {
    AddCategoryPopupView(screenMode: .constant(.addCategory), mealGroups: .constant(MockData.mealGroupList))
}
