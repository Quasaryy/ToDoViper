// Persistence.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: false)
        let viewContext = result.container.viewContext
        
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.fetchLimit = 5
        
        do {
            let todos = try viewContext.fetch(fetchRequest)
            if todos.isEmpty {
                // If there is no data
                let sampleTasks = [
                    (id: 1, todo: "Sample Task 1", completed: false),
                    (id: 2, todo: "Sample Task 2", completed: true),
                    (id: 3, todo: "Sample Task 3", completed: false),
                    (id: 4, todo: "Sample Task 4", completed: true),
                    (id: 5, todo: "Sample Task 5", completed: false)
                ]
                
                for task in sampleTasks {
                    let newTodo = TodoEntity(context: viewContext)
                    newTodo.id = Int64(task.id)
                    newTodo.todo = task.todo
                    newTodo.completed = task.completed
                    newTodo.createdAt = Date()
                }
                try viewContext.save()
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    let container: NSPersistentContainer
    
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
    
    func saveTodo(id: Int64, task: String, completed: Bool, createdAt: Date) {
        let context = container.viewContext
        let newTodo = TodoEntity(context: context)
        newTodo.id = id
        newTodo.todo = task
        newTodo.completed = completed
        newTodo.createdAt = createdAt
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}
