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
        Group {
            if isExpanded {
                ExpandedMealGroupView(group: group, isExpanded: $isExpanded)
                    .transition(.opacity)
            } else {
                MinimizedMealGroupView(group: group, isExpanded: $isExpanded)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

struct MinimizedMealGroupView: View {
    var group: MealGroup
    @Binding var isExpanded: Bool
    
    var body: some View {
        let (emblem, mixed, medium, heavy) = Color.emblemPalette(from: group.colour)
        
        VStack(alignment: .center, spacing: 10) {
            Text(group.name)
                .foregroundStyle(.black)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                withAnimation {
                    isExpanded = true
                }
            } label: {
                OpenButtonView()
                    .foregroundStyle(emblem.mix(with: .black, by: 0.3))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(AnimatedBackgroundGradient(colours: [
            emblem, emblem, medium, medium,
            emblem, emblem, medium, medium,
            mixed, mixed, .white, heavy,
            mixed, mixed, heavy, heavy
        ]).shadow(color: emblem.opacity(0.3), radius: 8, x: 0, y: 4))
        .padding(.horizontal)
    }
}

struct ExpandedMealGroupView: View {
    var group: MealGroup
    @Binding var isExpanded: Bool
    
    var body: some View {
        let (emblem, mixed, medium, heavy) = Color.emblemPalette(from: group.colour)
        
        VStack(spacing: 0) {
            HStack {
                Text(group.name)
                    .foregroundStyle(.black)
                    .font(.title3.weight(.bold))
                Spacer()
                Button {
                    withAnimation {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(emblem.mix(with: .black, by: 0.3))
                        .shadow(radius: 2)
                }
            }
            .padding()
            .background(
                AnimatedBackgroundGradient(colours: [
                    emblem, emblem, medium, medium,
                    emblem, emblem, medium, medium,
                    mixed, mixed, .white, heavy,
                    mixed, mixed, heavy, heavy
                ], clipToShape: false)
            )
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(group.meals, id: \.id) { meal in
                        FoodItemView(foodItem: meal,
                                     subtextColor: Color(.darkGray),
                                     backgroundColor: .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 600)
            
            MealGroupBottomEdge(emblemColour: emblem,
                                mixedColour: mixed,
                                medMixedColour: medium,
                                heavyMixedColour: heavy)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .padding(.horizontal)
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
                ], clipToShape: false))
                .frame(maxHeight: 10)
            Line()
                .frame(height: 1)
                .background(emblemColour)
        }
    }
}

private extension Color {
    static func emblemPalette(from hex: String) -> (emblem: Color, mixed: Color, medium: Color, heavy: Color) {
        let emblem = Color(hex: hex)
        return (
            emblem,
            emblem.mix(with: Color(.systemGray6), by: 0.3),
            emblem.mix(with: Color(.systemGray6), by: 0.45),
            emblem.mix(with: Color(.systemGray6), by: 0.6)
        )
    }
}

#Preview {
    MealGroupView(group: MockData.sampleMealGroup)
    MealGroupView(group: MockData.sampleMealGroup, isExpanded: true)
}
