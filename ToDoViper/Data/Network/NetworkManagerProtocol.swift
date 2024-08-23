// NetworkManagerProtocol.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import Foundation

protocol NetworkManagerProtocol {
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
}
