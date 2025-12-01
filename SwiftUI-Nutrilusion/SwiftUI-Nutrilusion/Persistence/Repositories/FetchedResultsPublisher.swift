//
//  FetchedResultsPublisher.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-09-20.
//

import CoreData
import Combine

final class FetchedResultsPublisher<ResultType: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    private let subject: CurrentValueSubject<[ResultType], Never>
    private let controller: NSFetchedResultsController<ResultType>

    var publisher: AnyPublisher<[ResultType], Never> {
        subject.eraseToAnyPublisher()
    }

    init(fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) {
        fetchRequest.sortDescriptors = sortDescriptors

        self.controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        self.subject = CurrentValueSubject<[ResultType], Never>([])

        super.init()

        controller.delegate = self

        do {
            try controller.performFetch()
            subject.send(controller.fetchedObjects ?? [])
        } catch {
            print("Failed to fetch: \(error)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [ResultType] else { return }
        subject.send(objects)
    }
}
