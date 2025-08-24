//
//  NutrientItem.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import Foundation

struct NutrientItem: Identifiable {
    var id: UUID
    var name: String
    var amount: Double
    var unit: String
    var childNutrients: [NutrientItem]
    
    init(id: UUID = UUID(), name: String, amount: Double = 0, unit: String = "g", childNutrients: [NutrientItem] = []) {
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
            amount += child.amount
            
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
}
