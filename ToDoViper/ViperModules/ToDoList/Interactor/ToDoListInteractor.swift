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
    private let dataStore: TodoDataStore
    private let networkManager: NetworkManagerProtocol
    
    init(dataStore: TodoDataStore = PersistenceController.shared, networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.dataStore = dataStore
        self.networkManager = networkManager
    }
    
}

extension ToDoListInteractor: ToDoListInteractorInput {
    
    func fetchTodos() {
        DispatchQueue.global(qos: .background).async {
            let todos = self.dataStore.fetchTodos().sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
            
            DispatchQueue.main.async {
                if todos.isEmpty {
                    self.loadTodosFromNetwork()
                } else {
                    self.output?.didFetchTodos(todos)
                }
            }
        }
    }
    
    private func loadTodosFromNetwork() {
        networkManager.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                DispatchQueue.global(qos: .background).async {
                    self?.saveTodosToCoreData(todos)
                    let savedTodos = self?.dataStore.fetchTodos() ?? []
                    DispatchQueue.main.async {
                        self?.output?.didFetchTodos(savedTodos)
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
    
    func deleteTodoById(_ id: Int64) {
        DispatchQueue.global(qos: .background).async {
            self.dataStore.deleteTodo(id: id)
            self.fetchTodos() // Reloading the task list after deletion
        }
    }
    
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date) {
        DispatchQueue.global(qos: .background).async {
            self.dataStore.updateTodo(id: id, task: task, completed: completed, createdAt: createdAt)
            self.fetchTodos() // Reloading the task list after deletion
        }
    }
    
    func addTodo(task: String, completed: Bool, createdAt: Date) {
        DispatchQueue.global(qos: .background).async {
            let newId = (self.dataStore.fetchTodos().last?.id ?? 0) + 1
            self.dataStore.saveTodo(id: newId, task: task, completed: completed, createdAt: createdAt)
            self.fetchTodos() // Reloading the task list after deletion
        }
    }
    
    func createNewTodo() {
        let newTask = "New Task"
        let completed = false
        let createdAt = Date()
        
        addTodo(task: newTask, completed: completed, createdAt: createdAt)
    }
    
}
