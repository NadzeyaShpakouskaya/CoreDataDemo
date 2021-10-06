//
//  CoreDataStorageManager.swift
//  CoreDataDemo
//
//  Created by Nadzeya Shpakouskaya on 06/10/2021.
//

import CoreData

class CoreDataStorageManger {
    // MARK: - Singleton
    static let shared = CoreDataStorageManger()
    private init() {}
    
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createNewTaskEntity(description: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(
                    forEntityName: "Task",
                    in: persistentContainer.viewContext
                ) else { return nil }
        
        guard let task = NSManagedObject(
            entity: entityDescription,
            insertInto: persistentContainer.viewContext
        ) as? Task else { return nil }
        
        task.title = description
        return task
    }
}
