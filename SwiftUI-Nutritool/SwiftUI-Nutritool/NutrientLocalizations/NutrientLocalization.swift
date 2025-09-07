//
//  NutrientLocalization.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-09-04.
//

import Foundation


private struct NutrientLocalization: Codable, Identifiable {
    let id = UUID()
    let name: String
    let translations: [String: [String]]
    
    enum CodingKeys: String, CodingKey {
        case name
        case translations
    }
}

private struct NutrientLocalizationRoot: Codable {
    let localizations: [NutrientLocalization]
}

final class NutrientLocalizationHelper: ObservableObject {
    static let shared = NutrientLocalizationHelper()
    
    @Published private var localizations: [NutrientLocalization] = []
    private var keywordMap: [String: String] = [:] // key: normalized variant, value: canonical nutrient
    
    private init() {
        loadJSON()
        buildKeywords()
    }
    
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "nutrientLocalizations", withExtension: "json") else {
            print("Missing nutrientLocalizations.json in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let root = try JSONDecoder().decode(NutrientLocalizationRoot.self, from: data)
            localizations = root.localizations
        } catch {
            print("Failed to decode nutrientLocalizations.json: \(error)")
        }
    }
    
    private func normalize(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[^a-z]", with: "", options: .regularExpression)
    }
    
    private func buildKeywords() {
        for loc in localizations {
            for variants in loc.translations.values {
                for variant in variants {
                    keywordMap[normalize(variant)] = loc.name
                }
            }
        }
    }
    
    func canonicalName(for raw: String) -> String? {
        let cand = normalize(raw)
        
        if let exact = keywordMap[cand] {
            return exact
        }
        
        for (variant, canonical) in keywordMap {
            if cand.contains(variant) || variant.contains(cand) {
                return canonical
            }
        }
        
        return nil
    }
    
    func variants(for nutrient: String, lang: String) -> [String] {
        localizations.first(where: { $0.name == nutrient })?.translations[lang] ?? []
    }
}
