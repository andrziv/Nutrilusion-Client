//
//  NutrientItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

enum NutrientUnit: String, Codable, CustomStringConvertible, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case grams, milligrams, micrograms
    
    public var description: String {
        switch self {
        case .grams:  return "g"
        case .milligrams: return "mg"
        case .micrograms: return "µg"
        }
    }
    
    func convertTo(_ value: Double, to: NutrientUnit = .grams) -> Double {
        return (value * self.unitValue()) / to.unitValue()
    }
    
    func convertFrom(_ value: Double, from: NutrientUnit = .grams) -> Double {
        return (value * from.unitValue()) / self.unitValue()
    }
    
    // Pick best unit given a gram value
    static func bestUnit(for grams: Double) -> NutrientUnit {
        if 0 < grams && grams < 1 / 1_000 {
            return .micrograms
        } else if 1 / 1_000 <= grams && grams < 1 {
            return .milligrams
        } else {
            return .grams
        }
    }
    
    private func unitValue() -> Double {
        switch self {
        case .grams:  return 1.0
        case .milligrams: return 1 / 1000.0
        case .micrograms: return 1 / 1_000_000.0
        }
    }
}

struct NutrientItem: Identifiable, Equatable {
    let id: UUID = UUID()
    var name: String
    var amount: Double = 0
    var unit: NutrientUnit = .grams
    var childNutrients: [NutrientItem] = []
    
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
    mutating func appendChildNutrient(_ child: NutrientItem, directInsert: Bool = false) {
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
    
    /// Modify a nutrient and propagate changes upward.
    /// Returns true if modification was applied.
    @discardableResult
    mutating func modify(_ targetName: String, newValue: Double? = nil, newUnit: NutrientUnit? = nil) -> Bool {
        return modifyInternal(targetName, newValue: newValue, newUnit: newUnit) != nil
    }
    
    /// Recursive helper: returns delta in grams if modification occurred
    private mutating func modifyInternal(_ targetName: String, newValue: Double?, newUnit: NutrientUnit?) -> Double? {
        // Case 1: this node matches
        if name == targetName {
            let oldGrams = unit.convertTo(amount)
            applyModification(newValue: newValue, newUnit: newUnit)
            let newGrams = unit.convertTo(amount)
            return newGrams - oldGrams
        }
        
        // Case 2: search children
        for i in childNutrients.indices {
            if let delta = childNutrients[i].modifyInternal(targetName, newValue: newValue, newUnit: newUnit) {
                applyDelta(delta) // apply change to self
                return delta
            }
        }
        
        return nil
    }
    
    /// Delete a nutrient by name from this node’s children (recursively).
    /// - Parameters:
    ///   - targetName: The nutrient to remove.
    ///   - adjustAmounts: Whether to subtract the removed amount from parent totals.
    /// - Returns: `true` if deletion occurred, `false` otherwise.
    @discardableResult
    mutating func deleteChildNutrient(_ targetName: String, adjustAmounts: Bool = true) -> Bool {
        if let index = childNutrients.firstIndex(where: { $0.name == targetName }) {
            let removed = childNutrients.remove(at: index)
            
            if adjustAmounts {
                // remove grams from self
                // TODO: consider additive solution (sum the other components instead of subtracting the removed components)
                let removedGrams = removed.totalInGrams()
                let currentGrams = unit.convertTo(amount)
                let newTotal = max(0, currentGrams - removedGrams)
                applyModification(newValue: newTotal)
            }
            return true
        }
        
        for i in childNutrients.indices {
            if childNutrients[i].deleteChildNutrient(targetName, adjustAmounts: adjustAmounts) {
                let sumGrams = childNutrients.map { $0.totalInGrams() }.reduce(0, +)
                applyModification(newValue: unit.convertFrom(sumGrams))
                return true
            }
        }
        
        return false
    }
    
    /// Helper: walks down a path of names, auto-creating if needed, and aggregates amounts.
    private mutating func insertAlongPath(path: [String], child: NutrientItem) {
        guard let first = path.first else { return }
        
        if first == name {
            // tally new totals given the added nutrient
            let childGrams = child.unit.convertTo(child.amount)
            let selfGrams = unit.convertTo(amount)
            let totalGrams = selfGrams + childGrams
            
            // change unit if needed to make sure that the numbers aren't too small or large
            optimizeUnitFor(totalGrams)
            
            let rest = Array(path.dropFirst())
            if let next = rest.first {
                if let index = childNutrients.firstIndex(where: { $0.name == next }) {
                    childNutrients[index].insertAlongPath(path: rest, child: child)
                } else {
                    var newNode = NutrientItem(name: next, amount: 0, unit: child.unit)
                    newNode.insertAlongPath(path: rest, child: child)
                    childNutrients.append(newNode)
                }
            }
        }
    }
    
    private mutating func optimizeUnitFor(_ newGramValue: Double) {
        let bestUnit = NutrientUnit.bestUnit(for: newGramValue)
        unit = bestUnit
        amount = unit.convertFrom(newGramValue)
    }
    
    /// Apply local update logic
    private mutating func applyModification(newValue: Double? = nil, newUnit: NutrientUnit? = nil) {
        if let newUnit = newUnit, let newValue = newValue {
            amount = newValue
            unit = newUnit
        } else if let newValue = newValue {
            amount = newValue
        } else if let newUnit = newUnit {
            let grams = unit.convertTo(amount)
            amount = newUnit.convertFrom(grams)
            unit = newUnit
        }
    }
    
    /// Apply a delta (grams) to this node’s amount
    private mutating func applyDelta(_ deltaGrams: Double) {
        let newGrams = max(0, unit.convertTo(amount) + deltaGrams)
        applyModification(newValue: unit.convertFrom(newGrams))
    }
    
    private func totalInGrams() -> Double {
        let selfGrams = unit.convertTo(amount)
        if childNutrients.isEmpty { return selfGrams }
        let childrenGrams = childNutrients.map { $0.totalInGrams() }.reduce(0, +)
        return childrenGrams
    }
}
