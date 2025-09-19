//
//  NutritoolModelConversions.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-18.
//

import Foundation
import CoreData

extension MealGroupEntity {
    func toModel() -> MealGroup {
        MealGroup(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            foodIDs: (self.foodItems as? Set<FoodItemEntity>)?.compactMap { $0.id } ?? [],
            colour: self.colour ?? ""
        )
    }
    
    func update(from model: MealGroup, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.colour = model.colour
        
        // Remove items that no longer belong
        if let existingFoodItems = self.foodItems as? Set<FoodItemEntity> {
            for foodEntity in existingFoodItems {
                if !model.foodIDs.contains(foodEntity.id ?? UUID()) {
                    self.removeFromFoodItems(foodEntity)
                }
            }
        }
        
        // Add new missing items
        for foodID in model.foodIDs {
            let fetch: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %@", foodID as CVarArg)
            if let found = try? context.fetch(fetch).first {
                if let currentItems = self.foodItems as? Set<FoodItemEntity> {
                    if !currentItems.contains(found) {
                        self.addToFoodItems(found)
                    }
                } else {
                    self.addToFoodItems(found)
                }
            }
        }
    }
}

extension FoodItemEntity {
    func toModel() -> FoodItem {
        FoodItem(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            calories: Int(self.calories),
            nutritionList: (self.nutrients as? Set<NutrientItemEntity>)?.map { $0.toModel() } ?? [],
            ingredientList: (self.ingredients as? Set<FoodItemEntity>)?.map { $0.toModel() } ?? [],
            servingAmount: self.servingAmount,
            servingUnit: self.servingUnit ?? "",
            servingUnitMultiple: self.servingUnitMultiple ?? ""
        )
    }
    
    func update(from model: FoodItem, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.calories = Int32(model.calories)
        self.servingAmount = model.servingAmount
        self.servingUnit = model.servingUnit
        self.servingUnitMultiple = model.servingUnitMultiple
        
        // Ingredients
        self.ingredients = NSSet()
        
        for ingredient in model.ingredientList {
            let entity = fetchFoodEntity(by: ingredient.id, in: context)
            ?? FoodItemEntity(context: context)
            entity.update(from: ingredient, in: context)
            self.addToIngredients(entity)
        }
        
        // Nutrients
        let oldNutrients = self.nutrients as? Set<NutrientItemEntity> ?? []
        self.nutrients = NSSet()
        
        for nutrient in model.nutritionList {
            let entity = oldNutrients.first(where: { $0.id == nutrient.id })
            ?? NutrientItemEntity(context: context)
            entity.update(from: nutrient, in: context)
            self.addToNutrients(entity)
        }
        
        for old in oldNutrients {
            if !(model.nutritionList.contains { $0.id == old.id }) {
                old.deleteRecursively(in: context)
            }
        }
    }
    
    func fetchFoodEntity(by id: UUID, in context: NSManagedObjectContext) -> FoodItemEntity? {
        let request: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch FoodItemEntity with id \(id): \(error)")
            return nil
        }
    }
}

extension NutrientItemEntity {
    func toModel() -> NutrientItem {
        NutrientItem(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            amount: self.amount,
            unit: NutrientUnit(rawValue: self.unit ?? "") ?? .grams,
            childNutrients: (self.childNutrients as? Set<NutrientItemEntity>)?.map { $0.toModel() } ?? []
        )
    }
    
    func update(from model: NutrientItem, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.amount = model.amount
        self.unit = model.unit.rawValue
        
        replaceChildNutrients(with: model.childNutrients, in: context)
    }
    
    /// Recursively delete this nutrient and all its child nutrients.
    func deleteRecursively(in context: NSManagedObjectContext) {
        let children = (self.childNutrients as? Set<NutrientItemEntity>) ?? []
        for child in children {
            child.deleteRecursively(in: context)
        }
        
        context.delete(self)
    }
    
    /**
     Replace the current childNutrients with the passed model list.
     Reuses existing entities when possible; creates new ones as needed;
     deletes orphaned child entities (recursively).
     */
    private func replaceChildNutrients(with models: [NutrientItem], in context: NSManagedObjectContext) {
        let currentChildrenSet = (self.childNutrients as? Set<NutrientItemEntity>) ?? []
        var currentById: [UUID: NutrientItemEntity] = [:]
        for childEntity in currentChildrenSet {
            if let childId = childEntity.id { currentById[childId] = childEntity }
        }
        
        var newEntities: [NutrientItemEntity] = []
        
        for modelChild in models {
            if let existing = currentById[modelChild.id] {
                existing.update(from: modelChild, in: context)
                newEntities.append(existing)
                currentById.removeValue(forKey: modelChild.id)
            } else if let fetched = Self.fetchNutrientEntity(by: modelChild.id, in: context) {
                fetched.update(from: modelChild, in: context)
                newEntities.append(fetched)
            } else {
                let created = NutrientItemEntity(context: context)
                created.update(from: modelChild, in: context)
                newEntities.append(created)
            }
        }
        
        self.childNutrients = NSSet(array: newEntities)
        
        // delete all orphaned children
        // This is fine because all NutrientItems are unique to their FoodItem holders,
        //   either directly or indirectly through being a child of one held by a FoodItem
        for (_, orphan) in currentById {
            orphan.deleteRecursively(in: context)
        }
    }
    
    static func fetchNutrientEntity(by id: UUID, in context: NSManagedObjectContext) -> NutrientItemEntity? {
        let request: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch NutrientItemEntity with id \(id): \(error)")
            return nil
        }
    }
}

