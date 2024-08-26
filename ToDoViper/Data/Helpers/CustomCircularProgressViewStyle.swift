// CustomCircularProgressViewStyle.swift
// ToDoViper
//
// Created by Yury Lebedev on 26.08.24.
// Copyright © 2024 www.LebedevApps.com Yury Lebedev. All rights reserved.
//
// This code is protected against unauthorized copying and modification.
// Any use, reproduction, or distribution of this code without prior written
// permission from the copyright owner is strictly prohibited.

import SwiftUI

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    
    // MARK: - Properties
    
    var lineWidth: CGFloat = 20.0
    var size: CGFloat = 100.0
    var color: Color = .blue
    @State private var isAnimating: Bool = false
    
    // MARK: - UI
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, lineWidth: lineWidth)
                .frame(width: size, height: size)
        }
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
}

#if DEBUG
#Preview {
    ProgressView()
        .progressViewStyle(CustomCircularProgressViewStyle())
}
#endif
