//
//  EditorialBlockEntry.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-25.
//


import SwiftUI

struct EditorialBlockEntry: View {
    let title: String
    @Binding var value: Double
    let unit: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .italic()
            
            Spacer()
            
            HStack(spacing: 4) {
                UnderlineDoubleField(
                    numberBinding: $value,
                    placeholder: "##",
                    cornerRadius: 6,
                    borderColour: .secondary.opacity(0.5)
                )
                .frame(width: 55)
                
                Text(unit)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 6)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(.secondaryText.mix(with: .backgroundColour, by: 0.65))
            )
        }
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondaryText.mix(with: .backgroundColour, by: 0.7))
            
        )
    }
}

struct EditorialBlockEntryInt: View {
    let title: String
    @Binding var value: Int
    let unit: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .italic()
            
            Spacer()
            
            HStack(spacing: 4) {
                UnderlineIntField(
                    numberBinding: $value,
                    placeholder: "##",
                    cornerRadius: 6,
                    borderColour: .secondary.opacity(0.5)
                )
                .frame(width: 55)
                
                Text(unit)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 6)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(.secondaryText.mix(with: .backgroundColour, by: 0.65))
            )
        }
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondaryText.mix(with: .backgroundColour, by: 0.7))
            
        )
    }
}
