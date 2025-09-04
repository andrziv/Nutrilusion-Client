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
    
    /// Modify a nutrient and propagate changes upward.
    /// Returns true if modification was applied.
    @discardableResult
    mutating func modify(_ targetName: String, newValue: Double? = nil, newUnit: NutrientUnit? = nil) -> Bool {
        return modifyInternal(targetName, newValue: newValue, newUnit: newUnit, optimizeUnitPropagation: true) != nil
    }
    
    /// Recursive helper: returns delta in grams if modification occurred
    private mutating func modifyInternal(_ targetName: String, newValue: Double?, newUnit: NutrientUnit?, optimizeUnitPropagation: Bool = false) -> Double? {
        // Case 1: this node matches
        if name == targetName {
            let oldGrams = unit.convertTo(amount)
            applyModification(newValue: newValue, newUnit: newUnit, optimizeUnit: (unit == newUnit) || (newUnit == nil)) // only optimize unit if the unit itself isn't being changed
            let newGrams = unit.convertTo(amount)
            return newGrams - oldGrams
        }
        
        // Case 2: search children
        for i in childNutrients.indices {
            if let delta = childNutrients[i].modifyInternal(targetName, newValue: newValue, newUnit: newUnit, optimizeUnitPropagation: optimizeUnitPropagation) {
                applyDelta(delta, optimizeUnit: optimizeUnitPropagation) // apply change to self
                return delta
            }
        }
        
        return nil
    }
    
    /// Adds nutrition value to the caller. If the nutrient doesn't exist in the tree, it will be added. If the target nutrient is a child of this nutrient, the changes will propagate from the target to the caller.
    /// - Parameters:
    ///   - other: The target nutrient whose values should be added to the tree. Nutrients are searched by name.
    ///   - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
    ///      - 0 < value in grams < 0.001: Unit is set to micrograms
    ///      - 0.001< value in grams < 1: unit is set to milligrams
    ///      - else: value is set to grams
    mutating func add(_ other: NutrientItem, optimizeUnit: Bool = true) {
        if name == other.name {
            let deltaGrams = other.unit.convertTo(other.amount, to: .grams)
            applyDelta(deltaGrams, optimizeUnit: optimizeUnit)
            
            for child in other.childNutrients {
                if let index = childNutrients.firstIndex(where: { $0.name == child.name }) {
                    childNutrients[index].add(child, optimizeUnit: optimizeUnit)
                } else {
                    childNutrients.append(child)
                }
            }
        } else {
            if let index = childNutrients.firstIndex(where: { $0.name == other.name }) {
                childNutrients[index].add(other, optimizeUnit: optimizeUnit)
            } else {
                childNutrients.append(other)
            }
        }
    }
    
    /// Subtracts nutrition value from the caller. If the target nutrient is a child of this nutrient, the changes will propagate from the target to the caller
    /// - Parameters:
    ///   - other: The target nutrient whose values should be subtracted from the tree. Nutrients are searched by name.
    ///   - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
    ///      - 0 < value in grams < 0.001: Unit is set to micrograms
    ///      - 0.001< value in grams < 1: unit is set to milligrams
    ///      - else: value is set to grams
    mutating func subtract(_ other: NutrientItem, optimizeUnit: Bool = true) {
        if name == other.name {
            let deltaGrams = -other.unit.convertTo(other.amount, to: .grams)
            applyDelta(deltaGrams, optimizeUnit: optimizeUnit)
            
            for child in other.childNutrients {
                if let index = childNutrients.firstIndex(where: { $0.name == child.name }) {
                    childNutrients[index].subtract(child, optimizeUnit: optimizeUnit)
                } else {
                    continue
                }
            }
        } else {
            if let index = childNutrients.firstIndex(where: { $0.name == other.name }) {
                childNutrients[index].subtract(other, optimizeUnit: optimizeUnit)
            } else {
                return
            }
        }
    }
    
    /// Delete a nutrient by name from this node’s children (recursively).
    /// - Parameters:
    ///   - targetName: The nutrient to remove.
    ///   - adjustAmounts: Whether to subtract the removed amount from parent totals.
    ///   - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
    ///      - 0 < value in grams < 0.001: Unit is set to micrograms
    ///      - 0.001< value in grams < 1: unit is set to milligrams
    ///      - else: value is set to grams
    /// - Returns: `true` if deletion occurred, `false` otherwise.
    @discardableResult
    mutating func deleteChildNutrient(_ targetName: String, adjustAmounts: Bool = true, optimizeUnit: Bool = false) -> Bool {
        if let index = childNutrients.firstIndex(where: { $0.name == targetName }) {
            let removed = childNutrients.remove(at: index)
            
            if adjustAmounts {
                // remove grams from self
                // TODO: consider additive solution (sum the other components instead of subtracting the removed components)
                let removedGrams = removed.totalInGrams()
                let currentGrams = unit.convertTo(amount)
                let newTotal = max(0, roundProper(currentGrams - removedGrams))
                applyModification(newValue: newTotal, optimizeUnit: optimizeUnit)
            }
            return true
        }
        
        for i in childNutrients.indices {
            if childNutrients[i].deleteChildNutrient(targetName, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit) {
                let sumGrams = childNutrients.map { $0.totalInGrams() }.reduce(0, +)
                applyModification(newValue: unit.convertFrom(sumGrams), optimizeUnit: optimizeUnit)
                return true
            }
        }
        
        return false
    }
    
    /// Apply local update logic
    private mutating func applyModification(newValue: Double? = nil, newUnit: NutrientUnit? = nil, unitConversion: Bool = false, optimizeUnit: Bool = false) {
        if let newUnit = newUnit, let newValue = newValue {
            amount = newValue
            unit = newUnit
        } else if let newValue = newValue {
            amount = newValue
        } else if let newUnit = newUnit {
            if unitConversion {
                let grams = unit.convertTo(amount)
                amount = newUnit.convertFrom(grams)
            }
            unit = newUnit
        }
        
        if optimizeUnit {
            optimizeUnitFor(unit.convertTo(amount, to: .grams))
        }
    }
    
    private mutating func optimizeUnitFor(_ newGramValue: Double) {
        let bestUnit = NutrientUnit.bestUnit(for: newGramValue)
        unit = bestUnit
        amount = unit.convertFrom(newGramValue)
    }
    
    /// Apply a delta (grams) to this node’s amount
    private mutating func applyDelta(_ deltaGrams: Double, optimizeUnit: Bool = false) {
        let newGrams = max(0, roundProper(unit.convertTo(amount) + deltaGrams))
        applyModification(newValue: unit.convertFrom(newGrams), optimizeUnit: optimizeUnit)
    }
    
    private func totalInGrams() -> Double {
        let selfGrams = unit.convertTo(amount)
        if childNutrients.isEmpty { return selfGrams }
        let childrenGrams = childNutrients.map { $0.totalInGrams() }.reduce(0, +)
        return childrenGrams
    }
    
    // used to get around Swift's ridiculous Double implementation where 1.001 - 0.001 results in a value < 1
    private func roundProper(_ value: Double) -> Double {
        return round(value, exp: 6)
    }
    
    /// add helper (uses path)
    private mutating func add(_ value: Double, unit: NutrientUnit, path: [String], optimizeUnit: Bool = true) {
        guard let first = path.first else { return }
        
        if first == name {
            let deltaGrams = unit.convertTo(value, to: .grams)
            applyDelta(deltaGrams, optimizeUnit: optimizeUnit)
            
            let rest = Array(path.dropFirst())
            if let next = rest.first {
                if let index = childNutrients.firstIndex(where: { $0.name == next }) {
                    childNutrients[index].add(value, unit: unit, path: rest, optimizeUnit: optimizeUnit)
                } else {
                    var newNode = NutrientItem(name: next, amount: 0, unit: unit)
                    newNode.add(value, unit: unit, path: rest, optimizeUnit: optimizeUnit)
                    childNutrients.append(newNode)
                }
            }
        }
    }
}
