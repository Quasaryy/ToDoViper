// ToDoListInteractorTests.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import XCTest
@testable import ToDoViper

// Mock for NetworkManager
class NetworkManagerMock: NetworkManagerProtocol {
    var shouldReturnError = false
    var todos = [Todo]()
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NetworkError.invalidURL))
        } else {
            completion(.success(todos))
        }
    }
}

// Mock for ToDoListInteractorOutput
class ToDoListInteractorOutputMock: ToDoListInteractorOutput {
    var todos = [TodoEntity]()
    var error: Error?
    
    func didFetchTodos(_ todos: [TodoEntity]) {
        self.todos = todos
    }
    
    func didFailToFetchTodos(with error: Error) {
        self.error = error
    }
}

class ToDoListInteractorTests: XCTestCase {
    
    var interactor: ToDoListInteractor!
    var output: ToDoListInteractorOutputMock!
    var persistenceController: PersistenceController!
    var networkManager: NetworkManagerMock!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        networkManager = NetworkManagerMock()
        output = ToDoListInteractorOutputMock()
        interactor = ToDoListInteractor(dataStore: persistenceController, networkManager: networkManager)
        interactor.output = output
    }
    
    func testFetchTodosFromNetwork() {
        // Arrange
        networkManager.todos = [Todo(id: 1, todo: "Network Task", completed: false)]
        persistenceController.saveTodo(id: 1, task: "Local Task", completed: false, createdAt: Date())
        persistenceController.deleteTodo(id: 1)
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch todos from network")
        interactor.fetchTodos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Assert
            XCTAssertEqual(self.output.todos.count, 1)
            XCTAssertEqual(self.output.todos.first?.todo, "Network Task")
            XCTAssertEqual(self.output.todos.first?.completed, false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTodosFromCoreData() {
        // Arrange
        persistenceController.saveTodo(id: 1, task: "Test Task", completed: false, createdAt: Date())
        
        // Act
        interactor.fetchTodos()
        
        // Assert
        XCTAssertEqual(output.todos.count, 1)
        XCTAssertEqual(output.todos.first?.todo, "Test Task")
    }
    
    func testDeleteTodo() {
        // Arrange
        persistenceController.saveTodo(id: 1, task: "Task to Delete", completed: false, createdAt: Date())
        
        // Act
        interactor.deleteTodoById(1)
        
        // Assert
        XCTAssertEqual(output.todos.count, 0)
        XCTAssertEqual(persistenceController.fetchTodos().count, 0)
    }
    
    func testToggleTodoStatus() {
        // Arrange
        persistenceController.saveTodo(id: 1, task: "Task to Toggle", completed: false, createdAt: Date())
        
        // Act
        let expectation = XCTestExpectation(description: "Status toggled")
        interactor.toggleTodoStatus(by: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Assert
            let updatedTask = self.persistenceController.fetchTodos().first { $0.id == 1 }
            XCTAssertEqual(updatedTask?.completed, true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
}
