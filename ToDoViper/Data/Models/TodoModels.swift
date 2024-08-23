// TodoModels.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import Foundation

struct TodoResponse: Decodable {
    let todos: [Todo]
}

struct Todo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
