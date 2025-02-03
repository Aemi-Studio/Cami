//
//  NavigationContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI
import OrderedCollections

@Observable
@MainActor
final class NavigationContext {
    var path: OrderedSet<NavigationPage> = []

    init(_ root: NavigationPage) {
        path = [root]
    }

    func push(_ item: NavigationPage) {
        path.append(item)
    }

    func pop() {
        current?.searchable?.query = ""
        isSearchFocused = false
        path.removeLast()
    }

    func previous() -> NavigationPage? {
        path.isEmpty ? nil : path[max(path.count - 2, 0)]
    }

    var isEmpty: Bool {
        path.count == 1
    }

    var current: NavigationPage? {
        get {
            path.last
        }
        set {
            if let newValue = newValue {
                if path.count > 0 {
                    path.update(newValue, at: path.count - 1)
                }
            }
        }
    }

    var isSearchFocused: Bool = false

    var isSearchFocusedBinding: Binding<Bool> {
        Binding {
            self.isSearchFocused
        } set: { value in
            self.isSearchFocused = value
        }
    }
}

extension EnvironmentValues {
    @Entry var navigation: NavigationContext?
}
