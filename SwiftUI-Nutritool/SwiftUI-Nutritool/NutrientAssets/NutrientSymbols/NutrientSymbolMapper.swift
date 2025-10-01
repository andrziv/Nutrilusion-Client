//
//  NutrientSymbolMapper.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-29.
//

import SwiftUI

private struct Nutrient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case symbol
    }
}

final class NutrientSymbolMapper {
    static let shared = NutrientSymbolMapper()
    
    private var symbolMap: [String: String] = [:]
    
    private init() {
        loadJSON()
    }
    
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "nutrientSymbols", withExtension: "json") else {
            print("Missing nutrientSymbols.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let nutrients = try JSONDecoder().decode([Nutrient].self, from: data)
            self.symbolMap = Dictionary(uniqueKeysWithValues: nutrients.map { ($0.name, $0.symbol) })
        } catch {
            print("Failed to decode nutrientSymbols.json: \(error)")
        }
    }
    
    func symbol(for nutrient: String) -> String {
        if let exists = symbolMap[nutrient] {
            return exists
        }
        return "questionmark.diamond.fill"
    }
    
    fileprivate func allNutrients() -> [Nutrient] {
        return symbolMap.map { Nutrient(name: $0.key, symbol: $0.value) }
    }
}

private struct NutrientSymbolPreview: View {
    let nutrients: [Nutrient]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(nutrients) { nutrient in
                    VStack {
                        Image(systemName: nutrient.symbol)
                            .font(.system(size: 28))
                            .padding()
                        
                        Text(nutrient.name)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 100)
                }
            }
            .padding()
        }
    }
}

#Preview {
    NutrientSymbolPreview(nutrients: NutrientSymbolMapper.shared.allNutrients())
}
