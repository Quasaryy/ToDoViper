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
    
    @Binding var taskText: String
    var isEditing: Bool
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
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
