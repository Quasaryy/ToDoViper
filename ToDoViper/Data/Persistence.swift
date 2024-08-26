// Persistence.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

protocol TodoDataStore {
    func saveTodo(id: Int64, task: String, completed: Bool, createdAt: Date)
    func fetchTodos() -> [TodoEntity]
    func addTodo(task: String, completed: Bool, createdAt: Date)
    func updateTodo(id: Int64, task: String, completed: Bool, createdAt: Date)
    func deleteTodo(id: Int64)
}

import CoreData

class PersistenceController {
    
    // MARK: - Properties
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: false)
        let viewContext = result.container.viewContext
        
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.fetchLimit = 5
        
        do {
            let todos = try viewContext.fetch(fetchRequest)
//            if todos.isEmpty {
//                // If there is no data
//                let sampleTasks = [
//                    (id: 1, todo: "Sample Task 1", completed: false),
//                    (id: 2, todo: "Sample Task 2", completed: true),
//                    (id: 3, todo: "Sample Task 3", completed: false),
//                    (id: 4, todo: "Sample Task 4", completed: true),
//                    (id: 5, todo: "Sample Task 5", completed: false)
//                ]
//
//                for task in sampleTasks {
//                    let newTodo = TodoEntity(context: viewContext)
//                    newTodo.id = Int64(task.id)
//                    newTodo.todo = task.todo
//                    newTodo.completed = task.completed
//                    newTodo.createdAt = Date()
//                }
//                try viewContext.save()
//            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    // MARK: - Initialization
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoViper")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
    }
    
    // MARK: - Private Methods
    
    private func performBackgroundTaskSync(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.performAndWait {
            block(backgroundContext)
            do {
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: backgroundContext)
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

// MARK: - TodoDataStore

extension PersistenceController: TodoDataStore {
    
    func saveTodo(id: Int64, task: String, completed: Bool, createdAt: Date) {
        performBackgroundTaskSync { context in
            let newTodo = TodoEntity(context: context)
            newTodo.id = id
            newTodo.todo = task
            newTodo.completed = completed
            newTodo.createdAt = createdAt
        }
    }
    
    func fetchTodos() -> [TodoEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        
        do {
            let todos = try context.fetch(fetchRequest)
            return todos
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addTodo(task: String, completed: Bool, createdAt: Date) {
        performBackgroundTaskSync { context in
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let lastTodo = try context.fetch(fetchRequest).first
                let newId: Int64 = (lastTodo?.id ?? 0) + 1
                let newTodo = TodoEntity(context: context)
                newTodo.id = newId
                newTodo.todo = task
                newTodo.completed = completed
                newTodo.createdAt = createdAt
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func updateTodo(id: Int64, task: String, completed: Bool, createdAt: Date) {
        performBackgroundTaskSync { context in
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            
            do {
                let todos = try context.fetch(fetchRequest)
                if let todo = todos.first {
                    todo.todo = task
                    todo.completed = completed
                    todo.createdAt = createdAt
                } else {
                    print("Todo with id \(id) not found.")
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func deleteTodo(id: Int64) {
        performBackgroundTaskSync { context in
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            
            do {
                let todos = try context.fetch(fetchRequest)
                if let todo = todos.first {
                    context.delete(todo)
                } else {
                    print("Todo with id \(id) not found.")
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
