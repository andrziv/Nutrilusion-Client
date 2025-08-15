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
        let emblem: Color = Color(hex: group.colour)
        
        VStack(spacing: 0) {
            MealGroupHeader(
                group: group,
                isExpanded: $isExpanded,
                emblem: emblem
            )
            
            MealGroupBody(
                group: group,
                isExpanded: isExpanded,
                emblem: emblem,
            )
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            ))
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(emblem.mix(with: .backgroundColour, by: 0.5))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isExpanded)
    }
}

struct MealGroupHeader: View {
    let group: MealGroup
    @Binding var isExpanded: Bool
    let emblem: Color
    
    var body: some View {
        HStack {
            Text(group.name)
                .foregroundStyle(.primaryText)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "xmark.circle.fill" : "chevron.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(emblem.mix(with: .primaryText, by: 0.1))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(FlowGradientBackground(colour: emblem, toMixWith: .backgroundColour.opacity(0.1)).overlay(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct MealGroupBody: View {
    let group: MealGroup
    let isExpanded: Bool
    let emblem: Color
    
    var body: some View {
        if isExpanded {
            VStack(spacing: 0) {
                LazyVScroll(items: group.meals) { meal in
                    FoodItemView(foodItem: meal)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxHeight: 600)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    MealGroupView(group: MockData.sampleMealGroup)
    MealGroupView(group: MockData.sampleMealGroup, isExpanded: true)
}
