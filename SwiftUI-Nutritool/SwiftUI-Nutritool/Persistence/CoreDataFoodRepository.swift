//
//  CoreDataFoodRepository.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import CoreData
import Combine

class CoreDataFoodRepository: NutriToolFoodRepositoryProtocol {
    let foodsPublisher: AnyPublisher<[FoodItem], Never>
    let mealGroupsPublisher: AnyPublisher<[MealGroup], Never>
    
    private let context: NSManagedObjectContext
    
    private var foodsFetcher: FetchedResultsPublisher<FoodItemEntity>!
    private var groupsFetcher: FetchedResultsPublisher<MealGroupEntity>!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let foodRequest: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "currentVersion != nil")
        foodRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodItemEntity.currentVersion?.version, ascending: false),
            NSSortDescriptor(keyPath: \FoodItemEntity.currentVersion?.name, ascending: true)
        ]
        foodsFetcher = FetchedResultsPublisher(fetchRequest: foodRequest, context: context)
        foodsPublisher = foodsFetcher.publisher
            .map { $0.map { $0.toModel() } }
            .eraseToAnyPublisher()
        
        let groupRequest: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
        groupRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        groupsFetcher = FetchedResultsPublisher(fetchRequest: groupRequest, context: context)
        mealGroupsPublisher = groupsFetcher.publisher
            .map { $0.map { $0.toModel() } }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Foods
    func addFood(_ food: FoodItem, to group: MealGroup) {
        context.performAndWait {
            guard let groupEntity = fetchMealGroupEntity(by: group.id, in: context) else {
                print("Tried to add food to non-existing group \(group.name), id: \(group.id).")
                return
            }
            
            if let latest = fetchLatestFoodEntity(by: food.foodItemID, in: context) {
                // if a fooditem already exists, we're just gonna move it between groups even if there were other differences
                //  doing this because it's a little strange to update thru adding. might change in the future.
                moveFood(latest, to: groupEntity, in: context)
                print("Moved existing FoodItem through addFood.")
            } else {
                // Insert brand-new FoodItemEntity version 1
                let newEntity = FoodItemEntity(context: context)
                var newModel = food
                newModel.withVersion(1)
                _ = newEntity.update(from: newModel, in: context)
                groupEntity.addToFoodItems(newEntity)
                print("Inserted new FoodItem \(newModel.name) (id: \(newModel.foodItemID), version: \(newModel.version)) into group \(group.name).")
            }
            
            _ = save()
        }
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        context.performAndWait {
            guard let groupEntity = fetchMealGroupEntity(by: group.id, in: context) else {
                return
            }
            
            if let latest = fetchLatestFoodEntity(by: food.foodItemID, in: context) {
                groupEntity.removeFromFoodItems(latest)
            }
            
            removeUnreferencedFoodVersions(for: food.foodItemID, in: context)
            removeUnreferencedNutrientVersions(for: food.foodItemID, in: context)
            _ = save()
        }
    }
    
    func updateFood(_ food: FoodItem) {
        let background = PersistenceController.shared.container.newBackgroundContext()
        
        background.perform { [self] in
            guard let foodItem = fetchLatestFoodEntity(by: food.foodItemID, in: background) else {
                print("Attempted to update non-existing FoodItem \(food.foodItemID). Aborting.")
                return
            }
            
            guard let latest = foodItem.currentVersion else {
                return
            }
            
            if latest.isEquivalent(to: food) {
                return
            }
            
            // If latest is not referenced anywhere upstream, mutate in-place without bumping version
            if !latest.isReferencedUpstream(in: background) {
                var inPlaceModel = food
                inPlaceModel.withVersion(Int(latest.version)) // keep version
                let output = resolveNutrientUpdates(for: inPlaceModel, latest: foodItem, insitu: true, in: background)
                inPlaceModel = output.0
                let updateOutput = foodItem.update(from: inPlaceModel, in: background)
                resolveDeletionScenario(foodItemID: inPlaceModel.foodItemID,
                                        currentVersion: inPlaceModel.version,
                                        foodItems: updateOutput.0,
                                        nutrientItems: updateOutput.1,
                                        in: background)
                
                _ = save(context: background)
                print("Updated FoodItem \(food.name) in-place (no version change).")
                return
            }
            
            let newVersion = Int(latest.version) + 1
            var updatedModel = food
            updatedModel.withVersion(newVersion)
            let output = resolveNutrientUpdates(for: updatedModel, latest: foodItem, insitu: false, in: background)
            updatedModel = output.0
            
            let newEntity = FoodItemVersionEntity(context: background)
            let updateOutput = newEntity.update(from: updatedModel, in: background)
            resolveDeletionScenario(foodItemID: updatedModel.foodItemID,
                                    currentVersion: updatedModel.version,
                                    foodItems: updateOutput.0,
                                    nutrientItems: updateOutput.1,
                                    in: background)
            foodItem.swapCurrentVersion(to: newEntity, in: background)
            
            if let groupEntity = foodItem.mealGroup {
                groupEntity.removeFromFoodItems(foodItem)
                groupEntity.addToFoodItems(foodItem)
            } else {
                print("Existing FoodItem \(food.name) (id: \(food.foodItemID), version: \(latest.version)) was not associated with a group.")
                background.delete(newEntity)
            }
            
            _ = save(context: background)
            print("Created new FoodItem version \(newVersion) for \(food.name) (id: \(food.foodItemID)).")
        }
    }
    
    func moveFood(_ food: FoodItem, from _: MealGroup, to newGroup: MealGroup)  {
        guard let groupEntity = fetchMealGroupEntity(by: newGroup.id, in: context) else {
            print("Tried to add food to non-existing group \(newGroup.name), id: \(newGroup.id).")
            return
        }
        
        if let latest = fetchLatestFoodEntity(by: food.foodItemID, in: context) {
            moveFood(latest, to: groupEntity, in: context)
            _ = save()
        }
    }
    
    private func moveFood(_ foodEntity: FoodItemEntity, to newGroup: MealGroupEntity, in context: NSManagedObjectContext) {
        if let currentGroup = (fetchMealGroupContainingFoodEntity(foodEntity, in: context)) {
            if currentGroup.id != newGroup.id {
                currentGroup.removeFromFoodItems(foodEntity)
                print("Unlinked existing FoodItem \(foodEntity.currentVersion?.name ?? "(nil)") (id: \(foodEntity.id!), version \(foodEntity.currentVersion?.version ?? -1)) from group \(currentGroup.name ?? "(nil)").")
            }
        }
        
        newGroup.addToFoodItems(foodEntity)
        print("Linked existing FoodItem \(foodEntity.currentVersion?.name ?? "(nil)") (id: \(foodEntity.id!), version \(foodEntity.currentVersion?.version ?? -1)) from group \(newGroup.name ?? "(nil)").")
    }
    
    // MARK: - Meal Groups
    func addMealGroup(_ group: MealGroup) {
        context.performAndWait {
            let entity = MealGroupEntity(context: context)
            entity.update(from: group, in: context)
            _ = save()
        }
    }
    
    func updateMealGroup(_ group: MealGroup) {
        context.performAndWait {
            if let entity = fetchMealGroupEntity(by: group.id, in: context) {
                entity.update(from: group, in: context)
                _ = save()
            }
        }
    }
    
    func deleteMealGroup(_ group: MealGroup) {
        context.performAndWait {
            if let entity = fetchMealGroupEntity(by: group.id, in: context) {
                context.delete(entity)
                _ = save()
            }
        }
    }
    
    private func resolveNutrientUpdates(for foodItem: FoodItem,
                                        latest entity: FoodItemEntity,
                                        insitu: Bool,
                                        in context: NSManagedObjectContext) -> (FoodItem, [NutrientItemEntity]) {
        let existingNutrients = (entity.currentVersion!.nutrients as? Set<NutrientItemEntity>) ?? []
        var existingByBaseID: [UUID: NutrientItemEntity] = [:]
        for n in existingNutrients {
            if let base = n.id {
                existingByBaseID[base] = n
            }
        }
        
        var updatedFoodItem = foodItem
        
        for (nutrientIndex, nutrientModel) in foodItem.nutritionList.enumerated() {
            let output = resolveNutrientUpdates(for: nutrientModel,
                                                with: existingByBaseID,
                                                latest: entity,
                                                insitu: insitu,
                                                in: context)
            updatedFoodItem.nutritionList[nutrientIndex] = output.0
            existingByBaseID = output.1
        }
        
        return (updatedFoodItem, Array(existingByBaseID.values))
    }
    
    private func resolveNutrientUpdates(for nutrientItem: NutrientItem,
                                        with entityNutrientMap: [UUID: NutrientItemEntity],
                                        latest entity: FoodItemEntity,
                                        insitu: Bool,
                                        in context: NSManagedObjectContext) -> (NutrientItem, [UUID: NutrientItemEntity]) {
        var remaining = entityNutrientMap
        var updatedNutrient = nutrientItem
        
        if let existing = remaining[nutrientItem.nutrientID] {
            for nutrientIndex in nutrientItem.childNutrients.indices {
                let output = resolveNutrientUpdates(for: nutrientItem.childNutrients[nutrientIndex],
                                                    with: remaining,
                                                    latest: entity,
                                                    insitu: insitu,
                                                    in: context)
                updatedNutrient.childNutrients[nutrientIndex] = output.0
                remaining = output.1
            }
            
            let currentVersion = Int(entity.currentVersion?.version ?? 0)
            let newestPlannedVersion = insitu ? currentVersion : currentVersion + 1
            if !existing.isEquivalent(to: nutrientItem) && existing.isReferencedElsewhere(foodItemID: entity.id!, olderThan: newestPlannedVersion, in: context) {
                updatedNutrient.withVersion(updatedNutrient.version + 1)
            }
            remaining.removeValue(forKey: nutrientItem.nutrientID)
        }
        
        return (updatedNutrient, remaining)
    }
    
    private func resolveDeletionScenario(foodItemID: UUID,
                                         currentVersion: Int,
                                         foodItems: [FoodItemVersionEntity],
                                         nutrientItems: [NutrientItemEntity],
                                         in context: NSManagedObjectContext) {
        removeUnreferencedNutrientItems(nutrientItems, foodItemID: foodItemID, currentVersion: currentVersion, in: context)
        removeUnreferencedFoodItems(foodItems, in: context)
    }
    
    private func removeUnreferencedFoodItems(_ foodItems: [FoodItemVersionEntity], in context: NSManagedObjectContext) {
        var foodCandidates = Set(foodItems)

        for food in foodItems {
            collectRecursively(from: food, into: &foodCandidates)
        }

        for food in foodCandidates {
            if !food.isReferenced(in: context) {
                context.delete(food)

                if let nutrients = food.nutrients as? Set<NutrientItemEntity> {
                    let foodItemID = food.parentItem!.id!
                    let currentVersion = Int(food.version)
                    removeUnreferencedNutrientItems(Array(nutrients), foodItemID: foodItemID, currentVersion: currentVersion, in: context)
                }
            }
        }
    }
    
    private func removeUnreferencedNutrientItems(_ nutrientItems: [NutrientItemEntity], foodItemID: UUID, currentVersion: Int, in context: NSManagedObjectContext) {
        for nutrient in nutrientItems {
            if !nutrient.isReferencedElsewhere(foodItemID: foodItemID, olderThan: currentVersion, in: context) {
                context.delete(nutrient)
            }
        }
    }
    
    private func collectRecursively(from food: FoodItemVersionEntity, into foodCandidates: inout Set<FoodItemVersionEntity>) {
        if let ingredients = food.ingredients as? Set<FoodItemVersionEntity> {
            for ingredient in ingredients where !foodCandidates.contains(ingredient) {
                foodCandidates.insert(ingredient)
                collectRecursively(from: ingredient, into: &foodCandidates)
            }
        }
    }
    
    private func fetchMealGroupContainingFoodEntity(_ food: FoodItemEntity, in context: NSManagedObjectContext) -> MealGroupEntity? {
        let request: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY foodItems == %@", food)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            return nil
        }
    }
    
    private func removeUnreferencedFoodVersions(for foodItemID: UUID, in context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "parent.id == %@", foodItemID as CVarArg)

        do {
            let versions = try context.fetch(fetch)
            for version in versions {
                if !version.isReferencedUpstream(in: context) {
                    context.delete(version)
                }
            }
        } catch {
            print("Failed to clean up FoodItemVersions for \(foodItemID): \(error)")
        }
    }

    private func removeUnreferencedNutrientVersions(for foodItemID: UUID, in context: NSManagedObjectContext) {
        let fetch: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "ANY foodItemVersions.parent.id == %@", foodItemID as CVarArg)

        do {
            let nutrients = try context.fetch(fetch)
            for nutrient in nutrients {
                if !nutrient.isReferencedElsewhere(foodItemID: foodItemID, olderThan: Int(Int32.max), in: context) {
                    context.delete(nutrient)
                }
            }
        } catch {
            print("Failed to clean up NutrientItemEntities for \(foodItemID): \(error)")
        }
    }
    
    @discardableResult
    private func save() -> Bool {
        return save(context: context)
    }
    
    private func save(context: NSManagedObjectContext) -> Bool {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Context had changes but couldn't apply them: \(error)")
                return false
            }
        }
        
        return true
    }
}
