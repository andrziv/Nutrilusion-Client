//
//  NutrientItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

enum NutrientUnit: String, Codable, CustomStringConvertible {
    case grams, milligrams, micrograms
    
    public var description: String {
        switch self {
        case .grams:  return "g"
        case .milligrams: return "mg"
        case .micrograms: return "µg"
        }
    }
    
    func toGrams(_ value: Double) -> Double {
        switch self {
        case .grams:  return value
        case .milligrams: return value / 1000.0
        case .micrograms: return value / 1_000_000.0
        }
    }
    
    func fromGrams(_ grams: Double) -> Double {
        switch self {
        case .grams:  return grams
        case .milligrams: return grams * 1000.0
        case .micrograms: return grams * 1_000_000.0
        }
    }
    
    // Pick best unit given a gram value
    static func bestUnit(for grams: Double) -> NutrientUnit {
        if grams < 0.001 {
            return .micrograms
        } else if grams < 1.0 {
            return .milligrams
        } else {
            return .grams
        }
    }
}

struct NutrientItem: Identifiable {
    var id: UUID
    var name: String
    var amount: Double
    var unit: NutrientUnit
    var childNutrients: [NutrientItem]
    
    init(id: UUID = UUID(), name: String, amount: Double = 0, unit: NutrientUnit = .grams, childNutrients: [NutrientItem] = []) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.childNutrients = childNutrients
    }
    
    func getChildNutrientValue(_ nutrientType: String) -> NutrientItem? {
        for nutrient in childNutrients {
            if nutrient.name == nutrientType {
                return nutrient
            }
        }
        
        for nutrient in childNutrients {
            if let found = nutrient.getChildNutrientValue(nutrientType) {
                return found
            }
        }
        
        return nil
    }
    
    func flattenChildren() -> [NutrientItem] {
        var result: [NutrientItem] = []
        for child in childNutrients {
            result.append(child)
            result.append(contentsOf: child.flattenChildren())
        }
        return result
    }
    
    /// Append a nutrient item.
    /// - Parameters:
    ///   - child: The nutrient item to add.
    ///   - directInsert: If true, bypasses the NutrientTree and just appends directly.
    mutating func append(_ child: NutrientItem, directInsert: Bool = false) {
        if directInsert {
            childNutrients.append(child)
            return
        }
        
        guard NutrientTree.shared.findNutrient(child.name) != nil else {
            print("Nutrient \(child.name) not found in configured tree.")
            return
        }
        
        let parents = NutrientTree.shared.getParents(of: child.name, ignoringGenerics: true)
        
        insertAlongPath(path: parents + [child.name], child: child)
    }
    
    /// Helper: walks down a path of names, auto-creating if needed, and aggregates amounts.
    private mutating func insertAlongPath(path: [String], child: NutrientItem) {
        guard let first = path.first else { return }
        
        if first == name {
            // tally new totals given the added nutrient
            let childGrams = child.unit.toGrams(child.amount)
            let selfGrams = unit.toGrams(amount)
            let totalGrams = selfGrams + childGrams
            
            // change unit if needed to make sure that the numbers aren't too small or large
            let bestUnit = NutrientUnit.bestUnit(for: totalGrams)
            unit = bestUnit
            amount = unit.fromGrams(totalGrams)
            
            let rest = Array(path.dropFirst())
            if let next = rest.first {
                if let idx = childNutrients.firstIndex(where: { $0.name == next }) {
                    childNutrients[idx].insertAlongPath(path: rest, child: child)
                } else {
                    var newNode = NutrientItem(name: next, amount: 0, unit: child.unit)
                    newNode.insertAlongPath(path: rest, child: child)
                    childNutrients.append(newNode)
                }
            }
        }
    }
}
