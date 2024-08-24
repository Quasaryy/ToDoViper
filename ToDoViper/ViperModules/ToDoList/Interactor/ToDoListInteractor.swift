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
    func deleteTodoById(_ id: Int64)
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date)
    func addTodo(task: String, completed: Bool, createdAt: Date)
    func createNewTodo()
}

protocol ToDoListInteractorOutput: AnyObject {
    func didFetchTodos(_ todos: [TodoEntity])
    func didFailToFetchTodos(with error: Error)
}

final class ToDoListInteractor {
    
    weak var output: ToDoListInteractorOutput?
    private let persistenceController: PersistenceController
    private let networkManager: NetworkManagerProtocol
    
    init(persistenceController: PersistenceController = .shared, networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.persistenceController = persistenceController
        self.networkManager = networkManager
    }
    
}

extension ToDoListInteractor: ToDoListInteractorInput {
    
    func fetchTodos() {
        let todos = persistenceController.fetchTodos().sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
        
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
    
    func deleteTodoById(_ id: Int64) {
        persistenceController.deleteTodo(id: id)
        fetchTodos() // Reloading the task list after deletion
    }
    
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date) {
        persistenceController.updateTodo(id: id, task: task, completed: completed, createdAt: createdAt)
        fetchTodos() // Reloading the task list after deletion
    }
    
    func addTodo(task: String, completed: Bool, createdAt: Date) {
        let newId = (persistenceController.fetchTodos().last?.id ?? 0) + 1
        persistenceController.saveTodo(id: newId, task: task, completed: completed, createdAt: createdAt)
        fetchTodos() // Reloading the task list after deletion
    }
    
    func createNewTodo() {
        let newTask = "New Task"
        let completed = false
        let createdAt = Date()
        
        addTodo(task: newTask, completed: completed, createdAt: createdAt)
    }
    
}
