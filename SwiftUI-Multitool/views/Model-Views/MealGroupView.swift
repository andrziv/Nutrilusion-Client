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
        let (emblem, mixed, medium, heavy) = Color.emblemPalette(from: group.colour)
        
        VStack(spacing: 0) {
            MealGroupHeader(group: group, isExpanded: $isExpanded, emblem: emblem)
                .padding()
                .background(
                    AnimatedBackgroundGradient(colours: [
                        emblem, emblem, medium, medium,
                        emblem, emblem, medium, medium,
                        mixed, mixed, .backgroundColour, heavy,
                        mixed, mixed, heavy, heavy
                    ], clipToShape: !isExpanded)
                )
            
            MealGroupBody(group: group, isExpanded: isExpanded, emblem: emblem, mixed: mixed, medium: medium, heavy: heavy)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryText.opacity(0.15), radius: 12, x: 0, y: 6)
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
                            .shadow(radius: 2)
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
    let mixed: Color
    let medium: Color
    let heavy: Color
    
    var body: some View {
        Group {
            if isExpanded {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(group.meals, id: \.id) { meal in
                            FoodItemView(foodItem: meal)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .primaryText.opacity(0.05), radius: 4, x: 0, y: 2)
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
        }
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
                    mixedColour, mixedColour, .backgroundColour, heavyMixedColour,
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
