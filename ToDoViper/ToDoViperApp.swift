// ToDoViperApp.swift
// ToDoViper
//
// Created by Yury Lebedev on 23.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import SwiftUI

@main
struct ToDoViperApp: App {

    var body: some Scene {
        WindowGroup {
            ToDoListAssembly.assemble()
        }
    }
}

#if DEBUG
#Preview {
    ToDoListAssembly.assemble()
}
#endif
