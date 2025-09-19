//
//  NutrientItem.swift
//  SwiftUI-Nutritool
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
        return (value * self.unitValue) / to.unitValue
    }
    
    func convertFrom(_ value: Double, from: NutrientUnit = .grams) -> Double {
        return (value * from.unitValue) / self.unitValue
    }
    
    /// Pick best unit given a gram value
    static func bestUnit(for grams: Double) -> NutrientUnit {
        if 0 < grams && grams < 1 / 1_000 {
            return .micrograms
        } else if 1 / 1_000 <= grams && grams < 1 {
            return .milligrams
        } else {
            return .grams
        }
    }
    
    private var unitValue: Double {
        switch self {
        case .grams:      return 1.0
        case .milligrams: return 1e-3
        case .micrograms: return 1e-6
        }
    }
}

struct NutrientItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var amount: Double = 0
    var unit: NutrientUnit = .grams
    var childNutrients: [NutrientItem] = []
    
    func getChildNutrientValue(_ nutrientType: String) -> NutrientItem? {
        if let direct = childNutrients.first(where: { $0.name == nutrientType }) {
            return direct
        }
        
        for child in childNutrients {
            if let found = child.getChildNutrientValue(nutrientType) {
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
    
    /**
     Modify a nutrient by name from this node’s children. Value changes will propagate upwards to *this* caller if the nutrient is a child to another nutrient.
     - Parameters:
         - targetName: The nutrient to remove.
         - newValue: Change the value of the nutrient with the given name. If the value is between a certain threshold, the unit will automatically change unless a newUnit value is given.
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
         - newUnit: Change the value of the unit.
     - Returns: `true` if modification occurred, `false` otherwise.
     */
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
                applyDelta(delta, optimizeUnit: optimizeUnitPropagation)
                return delta
            }
        }
        
        return nil
    }
    
    /**
     Adds nutrition value to the caller. If the nutrient doesn't exist at the expected location, it will be added. If the target nutrient is a child of this nutrient, the changes will propagate from the target to the caller.
     - Parameters:
         - other: The target nutrient whose values should be added to the tree. Nutrients are searched by name.
         - adjustAmounts: Set this to add values. Set this to false if you just want to add children to be automatically placed without affecting parent values.
         - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
         - directInsert: Ignores the proper nutrient hierarchy and adds nutrient as a direct child.
     - Returns: Whether or not the addition was successful.
     */
    @discardableResult
    mutating func add(_ other: NutrientItem, adjustAmounts: Bool = true, optimizeUnit: Bool = true, directInsert: Bool = false) -> Bool {
        if directInsert {
            addChild(other, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit)
            return true
        }
        
        guard NutrientTree.shared.findNutrient(other.name) != nil else {
            print("Nutrient \(other.name) not found in configured tree, discarding.")
            return false
        }
        
        let parents = NutrientTree.shared.getParents(of: other.name, ignoringGenerics: true)
        let path = parents + [other.name]
        
        let result = insertAlongPath(path: path, child: other, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit)
        return result
    }
    
    /// Insert along a resolved hierarchy path
    @discardableResult
    private mutating func insertAlongPath(path: [String], child: NutrientItem, adjustAmounts: Bool, optimizeUnit: Bool) -> Bool {
        guard let first = path.first else { return false }
        
        if first == name {
            if adjustAmounts {
                let childGrams = child.unit.convertTo(child.amount, to: .grams)
                let selfGrams = unit.convertTo(amount, to: .grams)
                let totalGrams = selfGrams + childGrams
                applyModification(newValue: unit.convertFrom(totalGrams), optimizeUnit: optimizeUnit)
            }
            
            let rest = Array(path.dropFirst())
            if let next = rest.first {
                if let index = childNutrients.firstIndex(where: { $0.name == next }) { // further down the existing chain
                    childNutrients[index].insertAlongPath(path: rest, child: child, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit)
                } else {
                    var newNode = NutrientItem(name: next, amount: child.amount, unit: child.unit) // create new nodes chain
                    newNode.insertAlongPath(path: rest, child: child, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit)
                    childNutrients.append(newNode)
                }
            }
            return true
        }
        
        return false
    }
    
    /**
     Subtracts nutrition value from the caller. If the target nutrient is a child of this nutrient, the changes will propagate from the target to the caller
     - Parameters:
         - other: The target nutrient whose values should be subtracted from the tree. Nutrients are searched by name.
             - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
     */
    mutating func subtract(_ other: NutrientItem, optimizeUnit: Bool = true) {
        if name == other.name {
            let deltaGrams = -other.unit.convertTo(other.amount, to: .grams)
            applyDelta(deltaGrams, optimizeUnit: optimizeUnit)
            
            for child in other.childNutrients {
                if let index = childNutrients.firstIndex(where: { $0.name == child.name }) {
                    childNutrients[index].subtract(child, optimizeUnit: optimizeUnit)
                }
            }
        } else if let index = childNutrients.firstIndex(where: { $0.name == other.name }) {
            childNutrients[index].subtract(other, optimizeUnit: optimizeUnit)
        }
    }
    
    /**
     Delete a nutrient by name from this node’s children (recursively).
     - Parameters:
         - targetName: The nutrient to remove.
         - adjustAmounts: Whether to subtract the removed amount from parent totals.
         - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
     - Returns: `true` if deletion occurred, `false` otherwise.
     */
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
    
    /**
     Recalculate this nutrient's entire nutrient subtree(s) values.
     - Parameters:
         - optimizeUnit: Whether or not the unit should be optimized given certain amount values:
             - 0 < value in grams < 0.001: Unit is set to micrograms
             - 0.001< value in grams < 1: unit is set to milligrams
             - else: value is set to grams
     */
    mutating func recalculateTree(optimizeUnit: Bool = true) {
        for i in childNutrients.indices {
            childNutrients[i].recalculateTree(optimizeUnit: optimizeUnit)
        }
        _ = recalculateFromChildren(optimizeUnit: optimizeUnit)
    }
    
    /// Recalculate this node’s value based on its children.
    /// Returns true if recalculation was performed.
    @discardableResult
    private mutating func recalculateFromChildren(optimizeUnit: Bool = true) -> Bool {
        guard !childNutrients.isEmpty else { return false }
        
        let childrenGrams = childNutrients.map { $0.totalInGrams() }.reduce(0, +)
        applyModification(newValue: unit.convertFrom(childrenGrams),
                          optimizeUnit: optimizeUnit)
        return true
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
    
    /// used to get around Swift's ridiculous Double implementation where 1.001 - 0.001 results in a value < 1
    private func roundProper(_ value: Double) -> Double {
        return round(value, exp: 6)
    }
    
    /// directly adds a child
    private mutating func addChild(_ other: NutrientItem, adjustAmounts: Bool, optimizeUnit: Bool) {
        if let idx = childNutrients.firstIndex(where: { $0.name == other.name }) {
            childNutrients[idx].add(other, adjustAmounts: adjustAmounts, optimizeUnit: optimizeUnit, directInsert: true)
        } else {
            let order = NutrientTree.shared.getChildOrder(of: name, ignoringGenerics: true)
            if !order.isEmpty, let targetIndex = findInsertIndex(for: other.name, order: order) {
                childNutrients.insert(other, at: targetIndex)
            } else {
                childNutrients.append(other) // no config order
            }
        }
        
        if adjustAmounts {
            let childGrams = other.unit.convertTo(other.amount, to: .grams)
            applyDelta(childGrams, optimizeUnit: optimizeUnit)
        }
    }

    /// find index to insert child based on config order
    private func findInsertIndex(for childName: String, order: [String]) -> Int? {
        guard let desiredIndex = order.firstIndex(of: childName) else { return nil }
        
        for (i, existing) in childNutrients.enumerated() {
            if let existingIdx = order.firstIndex(of: existing.name), existingIdx > desiredIndex {
                return i
            }
        }
        
        return nil 
    }
    
    /// add helper (uses raw path)
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
