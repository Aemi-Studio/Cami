//
//  MetaView.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI
import Combine

@MainActor
extension Hierarchy {

    @Observable
    final class Context: Identifiable {

        typealias ID = String
        typealias Content = (any View)

        private(set) var parent: Context?
        private(set) var child: Context?

        var ancestors: [Context] {
            if let parent {
                parent.ancestors + [parent]
            } else {
                []
            }
        }

        var id: String { (ancestors.map(\.title) + ["\(title)"]).joined(separator: "-") }

        private(set) var view: Content

        init(
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.view = content()
        }

        init(
            previous context: Context,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.parent = context
            self.view = content()
        }

        deinit {
            parent?.child = nil
            parent = nil
            child?.parent = nil
            child = nil
        }

        // MARK: - Variables

        private(set) var title: String = ""

        var searchQuery: String = ""
        var searchPrompt: String = "Search..."
        var isSearchPresented: Bool = false

        // Buttons
        typealias Buttons = (any View)
        private(set) var buttons: () -> Buttons = { EmptyView() }
    }
}

typealias ViewContext = Hierarchy.Context

extension ViewContext: Equatable {
    typealias Context = Hierarchy.Context
    static func == (lhs: Context, rhs: Context) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
extension ViewContext {
    @MainActor
    func navigate(to context: Context) -> Context {
        if let child {
            return child.navigate(to: context)
        } else {
            child = context.inherit(self)
            return child!
        }
    }

    @MainActor
    func navigate(@ViewBuilder to content: @escaping () -> Content) -> Context {
        navigate(to: Context(previous: self, content: content))
    }

    @MainActor
    func inherit(_ context: Context) -> Context {
        parent = context
        return self
    }

    @MainActor
    func shed() -> Context {
        child = nil
        return self
    }

    @MainActor
    func dismiss() -> Context? {
        if let parent = parent?.shed() {
            self.parent = nil
            return parent
        }
        return nil
    }
}

extension ViewContext {
    @MainActor
    @discardableResult
    func set<T>(_ keyPath: KeyPath<ViewContext, T>, to value: T) -> T? {
        if let path = keyPath as? ReferenceWritableKeyPath<ViewContext, T> {
            self[keyPath: path] = value
        }
        return self[keyPath: keyPath]
    }

    @MainActor
    @discardableResult
    func set<T>(_ keyPath: KeyPath<ViewContext, T>, to value: Binding<T>) -> T? {
        if let path = keyPath as? ReferenceWritableKeyPath<ViewContext, T> {
            self[keyPath: path] = value.wrappedValue
        }
        return self[keyPath: keyPath]
    }
}
