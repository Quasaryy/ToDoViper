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
    private let networkManager: NetworkManager
    
    init(persistenceController: PersistenceController = .shared, networkManager: NetworkManager = NetworkManager()) {
        self.persistenceController = persistenceController
        self.networkManager = networkManager
    }
    
}

extension ToDoListInteractor: ToDoListInteractorInput {
    
    func fetchTodos() {
        let todos = persistenceController.fetchTodos()
        
        if todos.isEmpty {
            // If there is no data in Core Data, load it from the network
            networkManager.fetchTodos { [weak self] result in
                switch result {
                case .success(let todos):
                    // Saving to Core Data
                    self?.saveTodosToCoreData(todos)
                    // Notifying Presenter of data receipt
                    self?.output?.didFetchTodos(self?.persistenceController.fetchTodos() ?? [])
                case .failure(let error):
                    // Presenter error notification
                    self?.output?.didFailToFetchTodos(with: error)
                }
            }
        } else {
            // If the data is in Core Data, pass it to Presenter
            output?.didFetchTodos(todos)
        }
    }
    
    private func saveTodosToCoreData(_ todos: [Todo]) {
        for todo in todos {
            persistenceController.saveTodo(id: Int64(todo.id), task: todo.todo, completed: todo.completed, createdAt: Date())
        }
    }
    
}
