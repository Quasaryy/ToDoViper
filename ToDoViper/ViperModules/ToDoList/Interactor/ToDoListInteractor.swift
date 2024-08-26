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
    func toggleTodoStatus(by id: Int64)
}

protocol ToDoListInteractorOutput: AnyObject {
    func didFetchTodos(_ todos: [TodoEntity])
    func didFailToFetchTodos(with error: Error)
}

final class ToDoListInteractor {
    
    // MARK: - Properties
    
    weak var output: ToDoListInteractorOutput?
    private let dataStore: TodoDataStore
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Initialization
    
    init(dataStore: TodoDataStore = PersistenceController.shared, networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.dataStore = dataStore
        self.networkManager = networkManager
    }
    
    // MARK: - Private Methods
    
    private func sortTodos(_ todos: [TodoEntity]) -> [TodoEntity] {
        return todos.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
    }
    
    private func loadTodosFromNetwork() {
        networkManager.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                DispatchQueue.global(qos: .background).async {
                    self?.saveTodosToCoreData(todos)
                    let savedTodos = self?.sortTodos(self?.dataStore.fetchTodos() ?? [])
                    DispatchQueue.main.async {
                        self?.output?.didFetchTodos(savedTodos ?? [])
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.output?.didFailToFetchTodos(with: error)
                }
            }
        }
    }
    
    private func saveTodosToCoreData(_ todos: [Todo]) {
        for todo in todos {
            dataStore.saveTodo(id: Int64(todo.id), task: todo.todo, completed: todo.completed, createdAt: Date())
        }
    }
    
}

// MARK: - ToDoListInteractorInput

extension ToDoListInteractor: ToDoListInteractorInput {
    
    func fetchTodos() {
        let todos = self.dataStore.fetchTodos()
        let sortedTodos = sortTodos(todos)
        
        if sortedTodos.isEmpty {
            self.loadTodosFromNetwork()
        } else {
            self.output?.didFetchTodos(sortedTodos)
        }
    }
    
    func deleteTodoById(_ id: Int64) {
        self.dataStore.deleteTodo(id: id)
        self.fetchTodos()
    }
    
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date) {
        self.dataStore.updateTodo(id: id, task: task, completed: completed, createdAt: createdAt)
        self.fetchTodos()
    }
    
    func toggleTodoStatus(by id: Int64) {
        if let todo = self.dataStore.fetchTodos().first(where: { $0.id == id }) {
            let newStatus = !todo.completed
            self.dataStore.updateTodo(id: id, task: todo.todo ?? "", completed: newStatus, createdAt: todo.createdAt ?? Date())
            self.fetchTodos()
        }
    }
    
    func addTodo(task: String, completed: Bool, createdAt: Date) {
        self.dataStore.addTodo(task: task, completed: completed, createdAt: createdAt)
        self.fetchTodos()
    }
    
}
