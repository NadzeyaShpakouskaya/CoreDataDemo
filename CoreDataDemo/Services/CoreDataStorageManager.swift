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
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    func saveContext() {
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
        saveContext()
        return task
    }
    
    func updateInfoFor(_ task: Task, with text: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "title = %@", task.title!)
        
        do {
            guard let task = try context.fetch(fetchRequest).first as? Task else { return }
            task.setValue(text, forKey: "title")
            saveContext()
        }
        catch let error {
            print(error)
        }
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func fetchAllTasks() -> [Task]? {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            return taskList
        } catch let error {
            
            print("Failed to fetch data", error)
            return nil
        }
    }
}
