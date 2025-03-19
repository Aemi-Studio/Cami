//
//  ViewContextModifier.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI

struct ViewContextModifier<T>: ViewModifier {

    @Environment(\.hierarchy) private var hierarchy

    private let keyPath: KeyPath<ViewContext, T>
    private let value: T

    init(_ keyPath: KeyPath<ViewContext, T>, to value: T) {
        self.keyPath = keyPath
        self.value = value
    }

    init(_ keyPath: KeyPath<ViewContext, T>, to value: Binding<T>) {
        self.keyPath = keyPath
        self.value = value.wrappedValue
    }

    func body(content: Content) -> some View {
        content.task(priority: .high) { @MainActor in hierarchy?.last().set(keyPath, to: value) }
    }
}

extension View {
    func set<T>(_ keyPath: sending KeyPath<ViewContext, T>, to value: T) -> some View where T: Sendable {
        modifier(ViewContextModifier(keyPath, to: value))
    }
    func set<T>(_ keyPath: sending KeyPath<ViewContext, T>, to value: Binding<T>) -> some View where T: Sendable {
        modifier(ViewContextModifier(keyPath, to: value))
    }
}
