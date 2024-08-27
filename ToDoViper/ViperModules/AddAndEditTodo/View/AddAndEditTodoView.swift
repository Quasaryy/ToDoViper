// AddAndEditTodoView.swift
// ToDoViper
//
// Created by Yury Lebedev on 26.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import SwiftUI

struct AddAndEditTodoView: View {
    
    // MARK: - Properties
    
    @Binding var taskText: String
    var isEditing: Bool
    var presenter: AddAndEditTodoPresenterInput
    var originalTask: TodoEntity?
    var onSave: () -> Void
    var onCancel: () -> Void
    
    // MARK: - UI
    
    var body: some View {
        makeUI()
    }
    
    private func makeUI() -> some View {
        VStack {
            Text(isEditing ? "Edit Task" : "Add New Task")
                .font(.headline)
                .padding()
            TextField(isEditing ? "Edit task title" : "Enter task title", text: $taskText)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .padding()
                Spacer()
                Button(isEditing ? "Save" : "Add") {
                    presenter.saveTask(taskText: taskText, isEditing: isEditing, originalTask: originalTask)
                    onSave()
                }
                .padding()
                .disabled(taskText.isEmpty)
            }
            .padding()
        }
        .padding()
    }
    
}
