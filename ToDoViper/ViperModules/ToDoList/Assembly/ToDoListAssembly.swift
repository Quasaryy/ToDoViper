// ToDoListAssembly.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import SwiftUI

struct ToDoListAssembly {
    
    static func assemble() -> some View {
        let interactor = ToDoListInteractor()
        let presenter = ToDoListPresenter(interactor: interactor)
        let view = ToDoListView(presenter: presenter)
        
        interactor.output = presenter
        
        return view
    }
    
}
