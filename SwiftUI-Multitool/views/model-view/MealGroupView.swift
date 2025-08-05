//
//  MealGroupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-02.
//

import SwiftUI

struct MealGroupView: View {
    @State var group: MealGroup
    @State var isExpanded: Bool = false
    
    var body: some View {
        if isExpanded {
            ExpandedMealGroupView(group: group, isExpanded: $isExpanded)
        } else {
            MinimizedMealGroupView(group: group, isExpanded: $isExpanded)
        }
    }
}

struct MinimizedMealGroupView: View {
    var group: MealGroup
    @Binding var isExpanded: Bool
    
    var body: some View {
        let emblemColour = Color(hex: group.colour)
        let mixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.3)
        let medMixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.45)
        let heavyMixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.6)
        VStack(alignment: .center) {
            HStack {
                Text(group.name)
                
                Spacer()
                
                Image(systemName: "plus.circle")
            }
            .foregroundStyle(.black)
            .font(.title3)
            .fontWeight(.bold)
            
            Button {
                withAnimation {
                    isExpanded = true
                }
            } label: {
                OpenButtonView()
                    .foregroundStyle(emblemColour.mix(with: .black, by: 0.3))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(AnimatedBackgroundGradient(colours: [
            emblemColour, emblemColour, medMixedColour, medMixedColour,
            emblemColour, emblemColour, medMixedColour, medMixedColour,
            mixedColour, mixedColour, .white, heavyMixedColour,
            mixedColour, mixedColour, heavyMixedColour, heavyMixedColour
        ]))
        .cornerRadius(15)
    }
}

struct ExpandedMealGroupView: View {
    var group: MealGroup
    @Binding var isExpanded: Bool
    
    var body: some View {
        let emblemColour = Color(hex: group.colour)
        let mixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.3)
        let medMixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.45)
        let heavyMixedColour = emblemColour.mix(with: Color(.systemGray6), by: 0.6)
        VStack(spacing: 0) {
            HStack() {
                ZStack {
                    Text(group.name)
                        .foregroundStyle(.black)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            .padding()
            .background(AnimatedBackgroundGradient(colours: [
                emblemColour, emblemColour, medMixedColour, medMixedColour,
                emblemColour, emblemColour, medMixedColour, medMixedColour,
                mixedColour, mixedColour, .white, heavyMixedColour,
                mixedColour, mixedColour, heavyMixedColour, heavyMixedColour
            ]))
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(group.meals, id: \.id) { meal in
                        FoodItemView(foodItem: meal,
                                     subtextColor: Color(.darkGray),
                                     backgroundColor: .white)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 600)
            
            Button {
                withAnimation {
                    isExpanded = false
                }
            } label: {
                CloseButtonView()
                    .foregroundStyle(emblemColour.mix(with: .black, by: 0.3))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            
            MealGroupBottomEdge(emblemColour: emblemColour,
                                mixedColour: mixedColour,
                                medMixedColour: medMixedColour,
                                heavyMixedColour: heavyMixedColour)
        }
        
   //     .cornerRadius(15)
    }
}

struct MealGroupHeaderBackground: View {
    var body: some View {
        Color.secondary
            .edgesIgnoringSafeArea(.all)
    }
}

struct MealGroupBottomEdge: View {
    let emblemColour: Color
    let mixedColour: Color
    let medMixedColour: Color
    let heavyMixedColour: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .opacity(0)
                .background(AnimatedBackgroundGradient(colours: [
                    emblemColour, emblemColour, medMixedColour, medMixedColour,
                    emblemColour, emblemColour, medMixedColour, medMixedColour,
                    mixedColour, mixedColour, .white, heavyMixedColour,
                    mixedColour, mixedColour, heavyMixedColour, heavyMixedColour
                ]))
            Line()
                .frame(height: 1)
                .background(emblemColour)
        }
    }
}

#Preview {
    MealGroupView(group: MockData.sampleMealGroup)
    MealGroupView(group: MockData.sampleMealGroup)
}
