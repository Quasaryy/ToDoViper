// AddAndEditTodoInteractorTests.swift
// ToDoViper
//
// Created by Yury Lebedev on 27.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import XCTest
@testable import ToDoViper

class AddAndEditTodoInteractorTests: XCTestCase {
    
    var interactor: AddAndEditTodoInteractor!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        interactor = AddAndEditTodoInteractor(dataStore: persistenceController)
    }
    
    func testUpdateTodo() {
        // Arrange
        let originalDate = Date()
        persistenceController.saveTodo(id: 1, task: "Old Task", completed: false, createdAt: originalDate)
        
        // Act
        interactor.updateTodoById(1, task: "Updated Task", completed: true, createdAt: originalDate)
        
        // Assert
        let todos = persistenceController.fetchTodos()
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.todo, "Updated Task")
        XCTAssertEqual(todos.first?.completed, true)
        XCTAssertEqual(todos.first?.createdAt, originalDate)
    }
    
    func testAddTodo() {
        // Arrange
        // There are no prerequisites in this test, so this block is empty.
        
        // Act
        interactor.addTodo(task: "New Task", completed: false, createdAt: Date())
        
        // Assert
        let todos = persistenceController.fetchTodos()
        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.todo, "New Task")
        XCTAssertEqual(todos.first?.completed, false)
    }
    
}
