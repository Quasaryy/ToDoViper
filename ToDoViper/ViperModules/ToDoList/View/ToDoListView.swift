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
    
    // MARK: - Properties
    
    @ObservedObject var presenter: ToDoListPresenter
    @State private var isShowingError: Bool = false
    @State private var isShowingAddEditTodoSheet: Bool = false
    @State private var newTaskText: String = ""
    @State private var isEditing: Bool = false
    @State private var editingTodoId: Int64? = nil
    @State private var isTaskCompleted: Bool = false
    @State private var originalCreatedAt: Date? = nil
    
    // MARK: - UI
    
    var body: some View {
        makeUI()
    }
    
    private func makeUI() -> some View {
        NavigationView {
            if presenter.isLoading {
                ProgressView()
                    .progressViewStyle(CustomCircularProgressViewStyle())
            } else {
                List {
                    ForEach(presenter.todos) { todo in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(todo.todo ?? "Unnamed Task")
                                Spacer()
                                Button(action: {
                                    presenter.didTapStatusIcon(todo.id)
                                }) {
                                    if todo.completed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.red)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            if let createdAt = todo.createdAt {
                                Text("Created at: \(formattedDate(createdAt))")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onTapGesture {
                            newTaskText = todo.todo ?? ""
                            isTaskCompleted = todo.completed
                            originalCreatedAt = todo.createdAt
                            isEditing = true
                            editingTodoId = todo.id
                            isShowingAddEditTodoSheet = true
                        }
                    }
                    .onDelete(perform: presenter.handleDelete)
                }
                .navigationTitle("To-Do List")
                .navigationBarItems(trailing: Button(action: {
                    newTaskText = ""
                    isEditing = false
                    editingTodoId = nil
                    isTaskCompleted = false
                    originalCreatedAt = nil
                    isShowingAddEditTodoSheet = true
                }) {
                    Image(systemName: "plus")
                })
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presenter.loadTodos()
            }
        }
        .alert(isPresented: $isShowingError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
        .onChange(of: isShowingAddEditTodoSheet) { previousValue, currentValue in
            if currentValue {
                if isEditing, let id = editingTodoId {
                    newTaskText = presenter.todos.first(where: { $0.id == id })?.todo ?? ""
                    isTaskCompleted = presenter.todos.first(where: { $0.id == id })?.completed ?? false
                    originalCreatedAt = presenter.todos.first(where: { $0.id == id })?.createdAt
                } else {
                    newTaskText = ""
                    isTaskCompleted = false
                    originalCreatedAt = nil
                }
            }
        }
        .sheet(isPresented: $isShowingAddEditTodoSheet) {
            let addEditInteractor = AddAndEditTodoInteractor(dataStore: PersistenceController.shared)
            let addEditPresenter = AddAndEditTodoPresenter(interactor: addEditInteractor)
            AddAndEditTodoView(
                taskText: $newTaskText,
                isEditing: isEditing,
                presenter: addEditPresenter,
                originalTask: isEditing ? presenter.todos.first { $0.id == editingTodoId } : nil,
                onSave: {
                    isShowingAddEditTodoSheet = false
                    presenter.loadTodos()
                },
                onCancel: {
                    isShowingAddEditTodoSheet = false
                }
            )
        }
        .onReceive(presenter.$errorMessage) { error in
            isShowingError = error != nil
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}

#if DEBUG
#Preview {
    let persistenceController = PersistenceController.preview
    let interactor = ToDoListInteractor(
        dataStore: persistenceController,
        networkManager: NetworkManager()
    )
    let presenter = ToDoListPresenter(interactor: interactor)
    interactor.output = presenter
    return ToDoListView(presenter: presenter)
}
#endif
