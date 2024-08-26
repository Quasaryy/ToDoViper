// NetworkManager.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
}

final class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    private let urlString: String
    
    init(session: URLSessionProtocol = URLSession.shared, urlString: String = "https://dummyjson.com/todos") {
        self.session = session
        self.urlString = urlString
    }
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.noData))
                    }
                    return
                }
                
                do {
                    let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(todoResponse.todos))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
    
}
