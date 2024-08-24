// ToDoListView.swift
// ToDoViper
//
// Created by Yury Lebedev on 24.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import SwiftUI

struct ToDoListView: View {
    
    @ObservedObject var presenter: ToDoListPresenter
    @State private var isShowingError: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(presenter.todos) { todo in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(todo.todo ?? "Unnamed Task")
                            Spacer()
                            if todo.completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.red)
                            }
                        }
                        if let createdAt = todo.createdAt {
                            Text("Created at: \(formattedDate(createdAt))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        presenter.didTapTodoItem(todo.id)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("To-Do List")
            .navigationBarItems(trailing: Button(action: {
                presenter.didTapAddTodoButton()
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                presenter.loadTodos()
            }
            .alert(isPresented: $isShowingError) {
                Alert(title: Text("Error"), message: Text(presenter.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
            }
        }
        .onReceive(presenter.$errorMessage) { error in
            isShowingError = error != nil
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let todo = presenter.todos[index]
            presenter.deleteTodoById(todo.id)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}
