// ToDoListInteractor.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import Foundation
import CoreData

protocol ToDoListInteractorInput {
    func fetchTodos()
}

protocol ToDoListInteractorOutput: AnyObject {
    func didFetchTodos(_ todos: [TodoEntity])
    func didFailToFetchTodos(with error: Error)
}

final class ToDoListInteractor {
    
    weak var output: ToDoListInteractorOutput?
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
}

extension ToDoListInteractor: ToDoListInteractorInput {
    
    func fetchTodos() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        
        do {
            let todos = try context.fetch(fetchRequest)
            output?.didFetchTodos(todos)
        } catch {
            output?.didFailToFetchTodos(with: error)
        }
    }
    
}
