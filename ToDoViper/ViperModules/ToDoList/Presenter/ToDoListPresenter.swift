// ToDoListPresenter.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

protocol ToDoListViewInput: AnyObject {
    func displayTodos(_ todos: [TodoEntity])
    func displayError(_ error: Error)
}

protocol ToDoListPresenterInput: AnyObject {
    func loadTodos()
    func didTapAddTodoButton()
    func didTapTodoItem(_ id: Int64)
}

import Foundation
import Combine

final class ToDoListPresenter: ObservableObject {
    
    @Published var todos: [TodoEntity] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let interactor: ToDoListInteractorInput
    weak var view: ToDoListViewInput?
    
    init(interactor: ToDoListInteractorInput) {
        self.interactor = interactor
    }
    
    func loadTodos() {
        isLoading = true
        interactor.fetchTodos()
    }
    
    func didTapAddTodoButton() {
        interactor.createNewTodo()
    }
    
    func didTapTodoItem(_ id: Int64) {
        print("tapped \(id)")
    }
    
    func didTapStatusIcon(_ id: Int64) {
        interactor.toggleTodoStatus(by: id)
    }
    
    func deleteTodoById(_ id: Int64) {
        interactor.deleteTodoById(id)
    }
    
}

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
