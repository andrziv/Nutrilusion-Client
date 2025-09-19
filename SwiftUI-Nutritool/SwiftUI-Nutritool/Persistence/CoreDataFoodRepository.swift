//
//  CoreDataFoodRepository.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-17.
//

import CoreData

class CoreDataFoodRepository: NutriToolFoodRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchFoods() -> [FoodItem] {
        let request: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
        return (try? context.fetch(request))?.map { $0.toModel() } ?? []
    }
    
    func fetchFoods(for group: MealGroup, limit: Int? = nil, offset: Int? = nil) -> [FoodItem] {
        let request: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY mealGroup.id == %@", group.id as CVarArg)
        if let limit = limit { request.fetchLimit = limit }
        if let offset = offset { request.fetchOffset = offset }
        return (try? context.fetch(request))?.map { $0.toModel() } ?? []
    }
    
    func addFood(_ food: FoodItem, to group: MealGroup) {
        let entity = FoodItemEntity(context: context)
        entity.update(from: food, in: context)
        
        if let groupEntity = fetchMealGroupEntity(by: group.id) {
            groupEntity.addToFoodItems(entity)
        }
        save()
    }
    
    func removeFood(_ food: FoodItem, from group: MealGroup) {
        if let entity = fetchFoodEntity(by: food.id) {
            context.delete(entity)
            save()
        }
    }
    
    func updateFood(_ food: FoodItem) {
        if let entity = fetchFoodEntity(by: food.id) {
            entity.update(from: food, in: context)
            save()
        }
    }
    
    func fetchMealGroups() -> [MealGroup] {
        let request: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
        return (try? context.fetch(request))?.map { $0.toModel() } ?? []
    }
    
    func addMealGroup(_ group: MealGroup) {
        let entity = MealGroupEntity(context: context)
        entity.update(from: group, in: context)
        save()
    }
    
    func updateMealGroup(_ group: MealGroup) {
        if let entity = fetchMealGroupEntity(by: group.id) {
            entity.update(from: group, in: context)
            save()
        }
    }
    
    func deleteMealGroup(_ group: MealGroup) {
        if let entity = fetchMealGroupEntity(by: group.id) {
            context.delete(entity)
            save()
        }
    }
    
    private func fetchMealGroupEntity(by id: UUID) -> MealGroupEntity? {
        let request: NSFetchRequest<MealGroupEntity> = MealGroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? context.fetch(request))?.first
    }
    
    private func fetchFoodEntity(by id: UUID) -> FoodItemEntity? {
        let request: NSFetchRequest<FoodItemEntity> = FoodItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? context.fetch(request))?.first
    }
    
    private func save() {
        if context.hasChanges { try? context.save() }
    }
}
