//
//  NutritoolModelConversions.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-18.
//

import CoreData
import SwiftUI

extension MealGroupEntity {
    func toModel() -> MealGroup {
        let sortedFoodItems = (self.foodItems as? Set<FoodItemEntity>)?
            .sorted {
                return ($0.currentVersion?.name ?? "") < ($1.currentVersion?.name ?? "")
            } ?? []
        
        return MealGroup(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            foodIDs: sortedFoodItems.compactMap { $0.id },
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
            if let found = fetchLatestFoodEntity(by: foodID, in: context) {
                if !((self.foodItems as? Set<FoodItemEntity>)?.contains(found) ?? false) {
                    self.addToFoodItems(found)
                }
            } else {
                continue
            }
        }
    }
    
    func hasFoodItems() -> Bool {
        return (self.foodItems?.count ?? 0) > 0
    }
}

extension LoggedMealItemEntity {
    func toModel() -> LoggedMealItem {
        return LoggedMealItem(
            id: self.id!,
            date: self.date!,
            meal: self.meal!.toModel(),
            servingMultiple: self.servingMultiple,
            importantNutrients: (self.importantNutrients as? Set<NutrientItemEntity>)?.map({ $0.toModel() }) ?? [],
            emblemColour: self.emblemColour ?? "ffffff"
        )
    }
    
    func update(from model: LoggedMealItem, in context: NSManagedObjectContext) -> (FoodItemVersionEntity?, [NutrientItemEntity]) {
        self.id = model.id
        self.date = model.date
        self.servingMultiple = model.servingMultiple
        self.emblemColour = model.emblemColour
        
        var unusedOldMeal: FoodItemVersionEntity? = nil
        if let currentMeal = self.meal, !currentMeal.isEquivalent(to: model.meal) {
            if let entity = fetchFoodVersionEntity(by: model.meal.id, in: context) {
                unusedOldMeal = currentMeal
                self.meal = entity
            }
        } else if self.meal == nil {
            if let entity = fetchFoodVersionEntity(by: model.meal.id, in: context) {
                self.meal = entity
            }
        }
        
        var oldNutrients = (self.importantNutrients as? Set<NutrientItemEntity> ?? [])
        var unusedNutrients: [NutrientItemEntity] = []
        for nutrientModel in model.importantNutrients {
            if let existing = oldNutrients.first(where: { $0.id == nutrientModel.nutrientID }) {
                if existing.version == nutrientModel.version {
                    oldNutrients.remove(existing)
                    continue
                }
                    
                self.removeFromImportantNutrients(existing)
            }
            
            if let entity = fetchNutrientEntity(by: nutrientModel.id, in: context) {
                self.addToImportantNutrients(entity)
                continue
            }
        }
        
        for unusedNutrient in oldNutrients {
            self.removeFromImportantNutrients(unusedNutrient)
        }
        
        unusedNutrients.append(contentsOf: NutrientItemEntity.collectAllDescendants(from: Array(oldNutrients), onlyDescendants: false))
        return (unusedOldMeal, unusedNutrients)
    }
}

extension FoodItemEntity {
    func toModel() -> FoodItem {
        let currentVersion = self.currentVersion!
        let id = self.id ?? UUID()
        return FoodItem(
            compositeID: currentVersion.compositeID ?? compositeId(id, version: Int(currentVersion.version)),
            id: id,
            version: Int(currentVersion.version),
            name: currentVersion.name ?? "",
            calories: Int(currentVersion.calories),
            nutritionList: (currentVersion.nutrients as? Set<NutrientItemEntity>)?.filter({ $0.parentNutrient == nil || $0.parentNutrient!.count == 0 }).map({ $0.toModel() }) ?? [],
            ingredientList: (currentVersion.ingredients as? Set<IngredientEntryEntity>)?.map { $0.toModel() } ?? [],
            servingAmount: currentVersion.servingAmount,
            servingUnit: currentVersion.servingUnit ?? "",
            servingUnitMultiple: currentVersion.servingUnitMultiple ?? ""
        )
    }
    
    func update(from model: FoodItem, in context: NSManagedObjectContext) -> ([IngredientEntryEntity], [NutrientItemEntity]) {
        self.id = model.foodItemID
        
        if let currentVersion = self.currentVersion {
            return currentVersion.update(from: model, in: context)
        }
        
        let newVersion = FoodItemVersionEntity(context: context)
        swapCurrentVersion(to: newVersion, in: context)
        return newVersion.update(from: model, in: context)
    }
    
    func swapCurrentVersion(to newVersion: FoodItemVersionEntity, in context: NSManagedObjectContext) {
        self.currentVersion = newVersion
        self.addToVersions(newVersion)
    }
    
    func hasVersionsAttached(in context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "parentItem == %@", self)
        request.fetchLimit = 1
        
        do {
            return !(try context.fetch(request).isEmpty)
        } catch {
            print("Failed to check most current version for IngredientEntryEntity \(self.id?.uuidString ?? "(nil)"): \(error)")
            return false
        }
    }
}

extension FoodItemVersionEntity {
    func toModel() -> FoodItem {
        let id = self.parentItem?.id ?? UUID()
        return FoodItem(
            compositeID: self.compositeID ?? compositeId(id, version: Int(self.version)),
            id: id,
            version: Int(self.version),
            name: self.name ?? "",
            calories: Int(self.calories),
            nutritionList: (self.nutrients as? Set<NutrientItemEntity>)?.filter({ $0.parentNutrient == nil || $0.parentNutrient!.count == 0 }).map({ $0.toModel() }) ?? [],
            ingredientList: (self.ingredients as? Set<IngredientEntryEntity>)?.map { $0.toModel() } ?? [],
            servingAmount: self.servingAmount,
            servingUnit: self.servingUnit ?? "",
            servingUnitMultiple: self.servingUnitMultiple ?? ""
        )
    }
    
    func update(from model: FoodItem, in context: NSManagedObjectContext) -> ([IngredientEntryEntity], [NutrientItemEntity]) {
        self.compositeID = model.id
        self.version = Int32(model.version)
        self.name = model.name
        self.calories = Int32(model.calories)
        self.servingAmount = model.servingAmount
        self.servingUnit = model.servingUnit
        self.servingUnitMultiple = model.servingUnitMultiple
        
        var oldIngredients = self.ingredients as? Set<IngredientEntryEntity> ?? []
        self.ingredients = NSSet()
        for ingredient in model.ingredientList {
            if let existing = oldIngredients.first(where: { $0.compositeID == ingredient.id }) {
                if existing.version == ingredient.version {
                    _ = existing.update(from: ingredient, in: context)
                    oldIngredients.remove(existing)
                    self.addToIngredients(existing)
                    continue
                }
                    
                self.removeFromIngredients(existing)
            } else if let entity = fetchIngredientEntryEntity(by: ingredient.id, in: context) {
                self.addToIngredients(entity)
                continue
            }
            
            let newEntity = IngredientEntryEntity(context: context)
            _ = newEntity.update(from: ingredient, in: context)
            self.addToIngredients(newEntity)
        }
        
        var oldNutrients = (self.nutrients as? Set<NutrientItemEntity> ?? []).filter({ $0.parentNutrient == nil || $0.parentNutrient!.count == 0 })
        var unusedNutrients: [NutrientItemEntity] = []
        for nutrientModel in model.nutritionList {
            if let existing = oldNutrients.first(where: { $0.id == nutrientModel.nutrientID }) {
                if existing.version == nutrientModel.version {
                    let unused = existing.update(from: nutrientModel, latestOwner: self, in: context)
                    oldNutrients.remove(existing)
                    unusedNutrients.append(contentsOf: unused)
                    continue
                }
                    
                self.removeFromNutrients(existing)
            } else if let entity = fetchNutrientEntity(by: nutrientModel.id, in: context) {
                let unused = entity.update(from: nutrientModel, latestOwner: self, in: context)
                self.addToNutrients(entity)
                unusedNutrients.append(contentsOf: unused)
                continue
            }
            
            let newEntity = NutrientItemEntity(context: context)
            _ = newEntity.update(from: nutrientModel, latestOwner: self, in: context)
            self.addToNutrients(newEntity)
        }
        
        for unusedIngredient in oldIngredients {
            self.removeFromIngredients(unusedIngredient)
        }
        
        let allOldNutrients = NutrientItemEntity.collectAllDescendants(from: Array(oldNutrients), onlyDescendants: false)
        for unusedNutrient in allOldNutrients {
            self.removeFromNutrients(unusedNutrient)
        }
        
        unusedNutrients.append(contentsOf: allOldNutrients)
        return (Array(oldIngredients), unusedNutrients)
    }
    
    func isEquivalent(to model: FoodItem) -> Bool {
        // basic fields
        if (self.name ?? "") != model.name { return false }
        if Int(self.calories) != model.calories { return false }
        if self.servingAmount != model.servingAmount { return false }
        if (self.servingUnit ?? "") != model.servingUnit { return false }
        if (self.servingUnitMultiple ?? "") != model.servingUnitMultiple { return false }
        
        // ingredient check
        let currentIngredients = (self.ingredients as? Set<IngredientEntryEntity>) ?? []
        let entityIngredientIDs = Set(currentIngredients.compactMap { $0.compositeID })
        let modelIngredientIDs = Set(model.ingredientList.map { $0.id })
        if entityIngredientIDs != modelIngredientIDs {
            return false
        }
        
        // nutrient checks
        let currentNutrients = (self.nutrients as? Set<NutrientItemEntity>) ?? []
        let entityNutrientIDs = Set(currentNutrients.compactMap { $0.compositeID })
        let modelNutrientIDs = Set(model.getAllNutrients().map { $0.id })
        if entityNutrientIDs != modelNutrientIDs {
            return false
        }
        
        var currentByBaseID: [UUID: NutrientItemEntity] = [:]
        for currentNutrient in currentNutrients {
            if let nutrientId = currentNutrient.id {
                currentByBaseID[nutrientId] = currentNutrient
            } else {
                return false
            }
        }
        
        for modelNutrient in model.nutritionList {
            guard let entityNutrient = currentByBaseID[modelNutrient.nutrientID] else {
                return false
            }
            if !entityNutrient.isEquivalent(to: modelNutrient) {
                return false
            }
        }
        
        return true
    }
    
    func isReferenced(ignore: Set<FoodItemVersionEntity>? = nil, in context: NSManagedObjectContext) -> Bool {
        do {
            let isReferencedByMealGroup = try isReferencedByMealGroup(in: context)
            if isMostCurrent(in: context) && isReferencedByMealGroup {
                return true
            }
            
            if try isReferencedAsIngredient(ignore: ignore, in: context) {
                return true
            }
            
            return try isReferencedByLoggedItems(in: context)
        } catch {
            print("Failed to check references for FoodItemVersionEntity \(self.compositeID ?? "(nil)"): \(error)")
            return true //assume referenced somewhere
        }
    }
    
    func isReferencedUpstream(ignore: Set<FoodItemVersionEntity>? = nil, in context: NSManagedObjectContext) -> Bool {
        do {
            if try isReferencedAsIngredient(ignore: ignore, in: context) {
                return true
            }
            
            return try isReferencedByLoggedItems(in: context)
        } catch {
            print("Failed to check references for FoodItemVersionEntity \(self.compositeID ?? "(nil)"): \(error)")
            return true //assume referenced somewhere
        }
    }
    
    private func isMostCurrent(in context: NSManagedObjectContext) -> Bool {
        guard let parent = self.isCurrentOf else {
            return false
        }
        
        if parent.currentVersion == self {
            return true
        }
        
        let fetch: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "parentItem == %@", parent)
        fetch.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false)]
        fetch.fetchLimit = 1
        
        do {
            let latest = try context.fetch(fetch).first
            return latest == self
        } catch {
            print("Failed to check most current version for FoodItem \(parent.id?.uuidString ?? "(nil)"): \(error)")
            return false
        }
    }
    
    private func isReferencedByMealGroup(in context: NSManagedObjectContext) throws -> Bool {
        let groupReq: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
        groupReq.predicate = NSPredicate(format: "ANY foodItems.currentVersion == %@", self)
        groupReq.fetchLimit = 1
        
        return !(try context.fetch(groupReq).isEmpty)
    }
    
    private func isReferencedAsIngredient(ignore: Set<FoodItemVersionEntity>?, in context: NSManagedObjectContext) throws -> Bool {
        let ingredientReq: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        var predicates: [NSPredicate] = [NSPredicate(format: "ANY ingredients.ingredient == %@", self)]
        
        if let ignore, !ignore.isEmpty {
            predicates.append(NSPredicate(format: "NOT (self IN %@)", ignore as NSSet))
        }
        
        ingredientReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        ingredientReq.fetchLimit = 1
        
        return !(try context.fetch(ingredientReq).isEmpty)
    }
    
    private func isReferencedByLoggedItems(in context: NSManagedObjectContext) throws -> Bool {
        let loggedReq: NSFetchRequest<LoggedMealItemEntity> = LoggedMealItemEntity.fetchRequest()
        loggedReq.predicate = NSPredicate(format: "meal == %@", self)
        loggedReq.fetchLimit = 1
        
        return !(try context.fetch(loggedReq).isEmpty)
    }
    
    func referencedAsIngredientBy(in context: NSManagedObjectContext) throws -> [FoodItemVersionEntity] {
        let ingredientReq: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        ingredientReq.predicate = NSPredicate(format: "ANY ingredients.ingredient == %@", self)
        
        return try context.fetch(ingredientReq)
    }
    
    func collectRecursively(into foodCandidates: inout Set<FoodItemVersionEntity>) {
        if let ingredients = self.ingredients as? Set<IngredientEntryEntity> {
            for ingredient in ingredients {
                if let foodItemIngredient = ingredient.ingredient, !foodCandidates.contains(foodItemIngredient) {
                    foodCandidates.insert(foodItemIngredient)
                    foodItemIngredient.collectRecursively(into: &foodCandidates)
                }
            }
        }
    }
}

extension IngredientEntryEntity {
    func toModel() -> IngredientEntry {
        IngredientEntry(
            compositeID: self.compositeID,
            id: self.id ?? UUID(),
            version: Int(self.version),
            ingredient: self.ingredient!.toModel(),
            servingMultiplier: self.servingMultiplier)
    }
    
    func update(from model: IngredientEntry, in context: NSManagedObjectContext) -> FoodItemVersionEntity? {
        self.compositeID = model.id
        self.id = model.ingredientID
        self.version = Int32(model.version)
        self.servingMultiplier = model.servingMultiplier
        
        var unusedFoodItemVersion: FoodItemVersionEntity? = nil
        if let currentIngredient = self.ingredient, !currentIngredient.isEquivalent(to: model.ingredient) {
            if let entity = fetchFoodVersionEntity(by: model.ingredient.id, in: context) {
                unusedFoodItemVersion = currentIngredient
                self.ingredient = entity
            }
        } else if self.ingredient == nil {
            if let entity = fetchFoodVersionEntity(by: model.ingredient.id, in: context) {
                self.ingredient = entity
            }
        }
        
        return unusedFoodItemVersion
    }
    
    func isEquivalent(to model: IngredientEntry) -> Bool {
        // basic fields
        if self.servingMultiplier != model.servingMultiplier { return false }
        
        // ingredient check
        if let currentIngredient = self.ingredient, !currentIngredient.isEquivalent(to: model.ingredient) {
            return false
        }
        
        return true
    }
    
    func isReferencedElsewhere(foodItemID: UUID, currentVersion version: Int, in context: NSManagedObjectContext) -> Bool {
        do {
           // let isReferencedAsIngredient = try isReferencedAsIngredient(in: context)
           // if isMostCurrent(in: context) && isReferencedAsIngredient {
           //     return true
           // }
            
            return try isReferencedAsIngredientIgnoring(foodItemID: foodItemID, currentVersion: version, in: context)
        } catch {
            print("Failed to check references for IngredientEntryEntity \(self.compositeID ?? "(nil)"): \(error)")
            return true //assume referenced somewhere
        }
    }
    
    private func isMostCurrent(in context: NSManagedObjectContext) -> Bool {
        let fetch: NSFetchRequest<IngredientEntryEntity> = IngredientEntryEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %@", self.id! as CVarArg)
        fetch.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false)]
        fetch.fetchLimit = 1
        
        do {
            let latest = try context.fetch(fetch).first
            return latest == self
        } catch {
            print("Failed to check most current version for IngredientEntryEntity \(self.id?.uuidString ?? "(nil)"): \(error)")
            return false
        }
    }
    
    private func isReferencedAsIngredientIgnoring(foodItemID: UUID, currentVersion version: Int, in context: NSManagedObjectContext) throws -> Bool {
        let ingredientReq: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        ingredientReq.predicate = NSPredicate(format: "ANY ingredients == %@ AND parentItem.id == %@ AND version != %d", self, foodItemID as CVarArg, version)
        ingredientReq.fetchLimit = 1
        
        return !(try context.fetch(ingredientReq).isEmpty)
    }
}

extension NutrientItemEntity {
    func toModel() -> NutrientItem {
        NutrientItem(
            compositeID: self.compositeID ?? compositeId(self.id ?? UUID(), version: Int(self.version)),
            id: self.id ?? UUID(),
            version: Int(self.version),
            name: self.name ?? "",
            amount: self.amount,
            unit: NutrientUnit(rawValue: self.unit ?? "") ?? .grams,
            childNutrients: (self.childNutrients as? Set<NutrientItemEntity>)?.map { $0.toModel() } ?? []
        )
    }
    
    func update(from model: NutrientItem, latestOwner: FoodItemVersionEntity, in context: NSManagedObjectContext) -> [NutrientItemEntity] {
        self.compositeID = model.id
        self.id = model.nutrientID
        self.version = Int32(model.version)
        self.name = model.name
        self.amount = model.amount
        self.unit = model.unit.rawValue
        
        return updateChildren(from: model, latestOwner: latestOwner, in: context)
    }
    
    private func updateChildren(from model: NutrientItem, latestOwner: FoodItemVersionEntity, in context: NSManagedObjectContext) -> [NutrientItemEntity] {
        guard let parentID = latestOwner.parentItem?.id else {
            print("updateChildren called with FoodItemVersionEntity missing parentItem")
            return []
        }
        
        let existingChildren = (self.childNutrients as? Set<NutrientItemEntity>) ?? []
        var existingByID: [UUID: NutrientItemEntity] = [:]
        for child in existingChildren {
            if let id = child.id {
                existingByID[id] = child
            }
        }
        
        var toKeep: [NutrientItemEntity] = []
        var toAdd: [NutrientItemEntity] = []
        var toRemove: [NutrientItemEntity] = []
        var childrenToReattach: [NutrientItemEntity] = []
        
        for childModel in model.childNutrients {
            if let existing = existingByID[childModel.nutrientID] {
                existingByID.removeValue(forKey: childModel.nutrientID)

                if existing.isEquivalent(to: childModel) {
                    toKeep.append(existing)
                    childrenToReattach.append(contentsOf: NutrientItemEntity.collectAllDescendants(from: [existing], onlyDescendants: true))
                } else {
                    let importantElsewhere = existing.isReferencedElsewhere(foodItemID: parentID, currentVersion: Int(latestOwner.version), in: context)

                    if !importantElsewhere {
                        let unused = existing.update(from: childModel, latestOwner: latestOwner, in: context)
                        toKeep.append(existing)
                        toRemove.append(contentsOf: unused)
                    } else {
                        let newChild = NutrientItemEntity(context: context)
                        let unused = newChild.update(from: childModel, latestOwner: latestOwner, in: context)
                        toAdd.append(newChild)
                        toRemove.append(contentsOf: unused)
                    }
                }
            } else if let fetched = fetchNutrientEntity(by: childModel.id, in: context) {
                if !fetched.isReferenced(in: context) && !fetched.isEquivalent(to: childModel) {
                    let unused = fetched.update(from: childModel, latestOwner: latestOwner, in: context)
                    toRemove.append(contentsOf: unused)
                }
                toKeep.append(fetched)
                childrenToReattach.append(contentsOf: NutrientItemEntity.collectAllDescendants(from: [fetched], onlyDescendants: true))
            } else {
                let newChild = NutrientItemEntity(context: context)
                _ = newChild.update(from: childModel, latestOwner: latestOwner, in: context)
                toAdd.append(newChild)
            }
        }

        let abandoned = Array(existingByID.values)
        toRemove.append(contentsOf: NutrientItemEntity.collectAllDescendants(from: abandoned, onlyDescendants: false))

        for child in toRemove {
            self.removeFromChildNutrients(child)
        }

        for child in toAdd + toKeep {
            self.addToChildNutrients(child)
            child.addToNutrientOf(latestOwner)
        }

        for recursiveChild in childrenToReattach {
            recursiveChild.addToNutrientOf(latestOwner)
        }

        return toRemove
    }
    
    func isEquivalent(to model: NutrientItem) -> Bool {
        // basic fields
        if (self.name ?? "") != model.name { return false }
        if self.amount != model.amount { return false }
        if (self.unit ?? "") != model.unit.rawValue { return false }
        
        // child nutrient checks
        let currentChildren = (self.childNutrients as? Set<NutrientItemEntity>) ?? []
        if currentChildren.count != model.childNutrients.count {
            return false
        }
        
        var childrenByBaseID: [UUID: NutrientItemEntity] = [:]
        for childNutrient in currentChildren {
            if let childId = childNutrient.id {
                childrenByBaseID[childId] = childNutrient
            }
            else {
                return false
            }
        }
        
        for childModel in model.childNutrients {
            guard let childEntity = childrenByBaseID[childModel.nutrientID] else {
                return false
            }
            if !childEntity.isEquivalent(to: childModel) {
                return false
            }
        }
        
        return true
    }
    
    func isReferenced(in context: NSManagedObjectContext) -> Bool {
        do {
            if try isReferencedByFoodItems(in: context) {
                return true
            }
            
            if try isReferencedByLoggedItems(in: context) {
                return true
            }
            
            return try isReferencedAsChild(in: context)
        } catch {
            print("Failed to check references for NutrientItemEntity '\(self.name ?? "(nil)")' (id: \(self.id?.uuidString ?? "(nil)"), version: \(self.version): \(error)")
            return true //assume referenced somewhere
        }
    }
    
    func isReferencedElsewhere(foodItemID: UUID, currentVersion version: Int, in context: NSManagedObjectContext) -> Bool {
        do {
            if try isReferencedByOtherFoodItems(foodItemID: foodItemID, currentVersion: version, in: context) {
                return true
            }
            
            if try isReferencedByLoggedItems(in: context) {
                return true
            }
            
            return try isReferencedAsChildInOlderFoodVersions(foodItemID: foodItemID, olderThan: version, in: context)
        } catch {
            print("Failed to check references for NutrientItemEntity '\(self.name ?? "(nil)")' (id: \(self.id?.uuidString ?? "(nil)"), version: \(self.version): \(error)")
            return true //assume referenced somewhere
        }
    }
    
    private func isReferencedByFoodItems(numberOfFoods: Int = 1, in context: NSManagedObjectContext) throws -> Bool {
        let foodReq: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        foodReq.predicate = NSPredicate(format: "ANY nutrients == %@", self)
        foodReq.fetchLimit = numberOfFoods
    
        return try context.fetch(foodReq).count >= numberOfFoods
    }
    
    private func isReferencedByOtherFoodItems(foodItemID: UUID, currentVersion version: Int, in context: NSManagedObjectContext) throws -> Bool {
        let foodReq: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        foodReq.predicate = NSPredicate(format: "ANY nutrients == %@ AND parentItem.id == %@ AND version != %d", self, foodItemID as CVarArg, version)
        foodReq.fetchLimit = 1
    
        return !(try context.fetch(foodReq).isEmpty)
    }
    
    private func isReferencedByLoggedItems(in context: NSManagedObjectContext) throws -> Bool {
        let loggedReq: NSFetchRequest<LoggedMealItemEntity> = LoggedMealItemEntity.fetchRequest()
        loggedReq.predicate = NSPredicate(format: "ANY importantNutrients == %@", self)
        loggedReq.fetchLimit = 1
        
        return !(try context.fetch(loggedReq).isEmpty)
    }
    
    private func isReferencedAsChild(numberOfParents: Int = 1, in context: NSManagedObjectContext) throws -> Bool {
        let parentReq: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
        parentReq.predicate = NSPredicate(format: "ANY childNutrients == %@", self)
        parentReq.fetchLimit = numberOfParents
        
        return try context.fetch(parentReq).count >= numberOfParents
    }

    private func isReferencedAsChildInOlderFoodVersions(foodItemID: UUID, olderThan version: Int, in context: NSManagedObjectContext) throws -> Bool {
        let parentReq: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
        parentReq.predicate = NSPredicate(format: "ANY childNutrients == %@ AND ANY nutrientOf.parentItem.id == %@ AND ANY nutrientOf.version < %d", self, foodItemID as CVarArg, version)
        parentReq.fetchLimit = 1
        
        return try !context.fetch(parentReq).isEmpty
    }

    static func collectAllDescendants(from entityList: [NutrientItemEntity], onlyDescendants: Bool) -> [NutrientItemEntity] {
        var result: [NutrientItemEntity] = []

        for nutrientEntity in entityList {
            if !onlyDescendants {
                result.append(nutrientEntity)
            }
            let childNutrients = (nutrientEntity.childNutrients as? Set<NutrientItemEntity>) ?? []
            result.append(contentsOf: collectAllDescendants(from: Array(childNutrients), onlyDescendants: false))
        }

        return result
    }
}

func compositeId(_ id: UUID, version: Int) -> String {
    return id.uuidString + "_v\(version)"
}
