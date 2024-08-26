// ToDoListPresenter.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

protocol ToDoListPresenterInput: AnyObject {
    func loadTodos()
    func didTapAddTodoButton(with: String)
    func didTapStatusIcon(_ id: Int64)
    func deleteTodoById(_ id: Int64)
    func updateTodo(id: Int64, task: String, completed: Bool, createdAt: Date)
}

import Foundation
import Combine

final class ToDoListPresenter: ObservableObject {
    
    // MARK: - Properties
    
    @Published var todos: [TodoEntity] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let interactor: ToDoListInteractorInput
    
    // MARK: - Initialization
    
    init(interactor: ToDoListInteractorInput) {
        self.interactor = interactor
    }
    
}

// MARK: - ToDoListPresenterInput

extension ToDoListPresenter: ToDoListPresenterInput {
    
    func loadTodos() {
        isLoading = true
        interactor.fetchTodos()
    }
    
    func didTapAddTodoButton(with task: String) {
        interactor.addTodo(task: task, completed: false, createdAt: Date())
    }
    
    func didTapStatusIcon(_ id: Int64) {
        print("tapped \(id)")
        interactor.toggleTodoStatus(by: id)
    }
    
    func deleteTodoById(_ id: Int64) {
        interactor.deleteTodoById(id)
    }
    
    func updateTodo(id: Int64, task: String, completed: Bool, createdAt: Date) {
        interactor.updateTodoById(id, task: task, completed: completed, createdAt: createdAt)
    }
    
}

// MARK: - ToDoListInteractorOutput

extension ToDoListPresenter: ToDoListInteractorOutput {
    
    func didFetchTodos(_ todos: [TodoEntity]) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.todos = todos
        }
    }
    
    func didFailToFetchTodos(with error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
}
