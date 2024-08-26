// AddAndEditTodoPresenter.swift
// ToDoViper
//
// Created by Yury Lebedev on 27.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

protocol AddAndEditTodoPresenterInput: AnyObject {
    func saveTask(taskText: String, isEditing: Bool, originalTask: TodoEntity?)
}

import Foundation

final class AddAndEditTodoPresenter {
    
    // MARK: - Properties
    
    private let interactor: ToDoListInteractorInput
    
    // MARK: - Initialization
    
    init(interactor: ToDoListInteractorInput) {
        self.interactor = interactor
    }
}

// MARK: - AddAndEditTodoPresenterInput

extension AddAndEditTodoPresenter: AddAndEditTodoPresenterInput {
    
    func saveTask(taskText: String, isEditing: Bool, originalTask: TodoEntity?) {
        if isEditing, let task = originalTask {
            interactor.updateTodoById(task.id, task: taskText, completed: task.completed, createdAt: task.createdAt ?? Date())
        } else {
            interactor.addTodo(task: taskText, completed: false, createdAt: Date())
        }
    }
    
}
