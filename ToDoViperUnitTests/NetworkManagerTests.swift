// NetworkManagerTests.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import XCTest
@testable import ToDoViper

// Mock for URLSession
class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        if url.absoluteString == "invalid_url" {
            completionHandler(nil, nil, NetworkError.invalidURL)
        } else {
            completionHandler(data, response, error)
        }
        return URLSessionDataTaskMock()
    }
}

// Mock for URLSessionDataTask
class URLSessionDataTaskMock: URLSessionDataTask {
    override func resume() {
        // Do nothing since the call is already handled in dataTask
    }
}

class NetworkManagerTests: XCTestCase {
    
    func testFetchTodosSuccess() {
        // Arrange
        let sessionMock = URLSessionMock()
        sessionMock.data = """
        {
            "todos": [
                {"id": 1, "todo": "Task 1", "completed": false},
                {"id": 2, "todo": "Task 2", "completed": true}
            ]
        }
        """.data(using: .utf8)
        
        let networkManager = NetworkManager(session: sessionMock)
        let expectation = XCTestExpectation(description: "Fetch todos successfully")
        
        // Act
        networkManager.fetchTodos { result in
            // Assert
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 2)
                XCTAssertEqual(todos[0].id, 1)
                XCTAssertEqual(todos[0].todo, "Task 1")
                XCTAssertEqual(todos[0].completed, false)
                XCTAssertEqual(todos[1].id, 2)
                XCTAssertEqual(todos[1].todo, "Task 2")
                XCTAssertEqual(todos[1].completed, true)
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTodosInvalidURL() {
        // Arrange
        let invalidURLString = "invalid_url"
        let networkManager = NetworkManager(session: URLSessionMock(), urlString: invalidURLString)
        let expectation = XCTestExpectation(description: "Handle invalid URL")
        
        // Act
        networkManager.fetchTodos { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure due to invalid URL, but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.invalidURL)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTodosNoData() {
        // Arrange
        let sessionMock = URLSessionMock()
        sessionMock.data = nil
        let networkManager = NetworkManager(session: sessionMock)
        let expectation = XCTestExpectation(description: "Handle no data scenario")
        
        // Act
        networkManager.fetchTodos { result in
            // Assert
            switch result {
            case .success(_):
                XCTFail("Expected failure due to no data, but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.noData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchTodosDecodingError() {
        // Arrange
        let sessionMock = URLSessionMock()
        // Incorrect data for decoding
        sessionMock.data = """
        { "invalid_json": }
        """.data(using: .utf8)
        let networkManager = NetworkManager(session: sessionMock)
        let expectation = XCTestExpectation(description: "Handle decoding error")
        
        // Act
        networkManager.fetchTodos { result in
            // Assert
            switch result {
            case .success(_):
                XCTFail("Expected failure due to decoding error, but got success")
            case .failure(let error):
                XCTAssertTrue(error is DecodingError)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
}
