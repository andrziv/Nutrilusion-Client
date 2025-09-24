//
//  CoreDataFetchers.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-19.
//

import CoreData

func fetchMealGroupEntity(by id: UUID, in context: NSManagedObjectContext) -> MealGroupEntity? {
    let request: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1
    
    do {
        return try context.fetch(request).first
    } catch {
        print("Failed to fetch MealGroupEntity with id \(id): \(error)")
        return nil
    }
}

func fetchFoodVersionEntity(by compositeID: String, in context: NSManagedObjectContext) -> FoodItemVersionEntity? {
    let request: NSFetchRequest<FoodItemVersionEntity> = FoodItemVersionEntity.fetchRequest()
    request.predicate = NSPredicate(format: "compositeID == %@", compositeID)
    request.fetchLimit = 1
    
    do {
        return try context.fetch(request).first
    } catch {
        print("Failed to fetch FoodItemEntity with id + version (compositeID) \(compositeID): \(error)")
        return nil
    }
}

func fetchLatestFoodEntity(by id: UUID, in context: NSManagedObjectContext) -> FoodItemEntity? {
    let request: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1
    
    do {
        return try context.fetch(request).first
    } catch {
        print("Failed to fetch latest FoodItemEntity with id \(id): \(error)")
        return nil
    }
}

func fetchNutrientEntity(by compositeID: String, in context: NSManagedObjectContext) -> NutrientItemEntity? {
    let request: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
    request.predicate = NSPredicate(format: "compositeID == %@", compositeID)
    request.fetchLimit = 1
    
    do {
        return try context.fetch(request).first
    } catch {
        print("Failed to fetch NutrientItemEntity with id + version (compositeID) \(compositeID): \(error)")
        return nil
    }
}

func fetchLatestNutrientEntity(by id: UUID, in context: NSManagedObjectContext) -> NutrientItemEntity? {
    let request: NSFetchRequest<NutrientItemEntity> = NutrientItemEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.sortDescriptors = [NSSortDescriptor(key: "version", ascending: false)]
    request.fetchLimit = 1
    
    do {
        return try context.fetch(request).first
    } catch {
        print("Failed to fetch latest NutrientItemEntity with id \(id): \(error)")
        return nil
    }
}
