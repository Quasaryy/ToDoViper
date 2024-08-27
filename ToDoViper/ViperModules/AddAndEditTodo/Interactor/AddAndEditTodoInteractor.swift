// AddAndEditTodoInteractor.swift
// ToDoViper
//
// Created by Yury Lebedev on 27.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import Foundation

protocol AddAndEditTodoInteractorInput: AnyObject {
    func addTodo(task: String, completed: Bool, createdAt: Date)
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date)
}

final class AddAndEditTodoInteractor {
    
    // MARK: - Properties
    
    private let dataStore: TodoDataStore
    
    // MARK: - Initialization
    
    init(dataStore: TodoDataStore) {
        self.dataStore = dataStore
    }
    
}

// MARK: - AddAndEditTodoInteractorInput

extension AddAndEditTodoInteractor: AddAndEditTodoInteractorInput {
    
    func addTodo(task: String, completed: Bool, createdAt: Date) {
        dataStore.addTodo(task: task, completed: completed, createdAt: createdAt)
    }
    
    func updateTodoById(_ id: Int64, task: String, completed: Bool, createdAt: Date) {
        dataStore.updateTodo(id: id, task: task, completed: completed, createdAt: createdAt)
    }
    
}
