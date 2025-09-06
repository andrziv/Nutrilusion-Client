//
//  MealGroupView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-02.
//

import SwiftUI

struct MealGroupView: View {
    var group: MealGroup
    @State var isExpanded: Bool = false
    
    var body: some View {
        let emblem = Color(hex: group.colour)
        
        VStack(spacing: 0) {
            MealGroupHeader(group: group, isExpanded: $isExpanded, emblem: emblem)
                .padding()
                .background(Rectangle().fill(emblem).blur(radius: 50))
                
            
            MealGroupBody(group: group, isExpanded: isExpanded, emblem: emblem)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .animation(.interpolatingSpring(mass: 1, stiffness: 188, damping: 23), value: isExpanded)
    }
}

struct MealGroupHeader: View {
    let group: MealGroup
    @Binding var isExpanded: Bool
    let emblem: Color
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(group.name)
                    .foregroundStyle(.primaryText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, isExpanded ? 0 : 10)
                
                if isExpanded {
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isExpanded = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(emblem.mix(with: .primaryText, by: 0.3))
                    }
                }
            }
            
            if !isExpanded {
                Button {
                    withAnimation {
                        isExpanded = true
                    }
                } label: {
                    OpenButtonView()
                        .foregroundStyle(emblem.mix(with: .primaryText, by: 0.3))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct MealGroupBody: View {
    let group: MealGroup
    let isExpanded: Bool
    let emblem: Color
    
    var body: some View {
        Group {
            if isExpanded {
                LazyVScroll(items: group.meals, spacing: 12) { meal in
                    FoodItemView(foodItem: meal)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding([.horizontal, .bottom])
                .frame(maxHeight: 600)
                
                MealGroupBottomEdge(emblemColour: emblem)
            }
        }
    }
}

struct MealGroupBottomEdge: View {
    let emblemColour: Color
    
    var body: some View {
        Line()
            .frame(height: 1)
            .background(emblemColour)
    }
}

#Preview {
    MealGroupView(group: MockData.sampleMealGroup)
    MealGroupView(group: MockData.sampleMealGroup, isExpanded: true)
}
