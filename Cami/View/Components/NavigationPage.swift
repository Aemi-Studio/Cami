//
//  NavigationPage.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

@Observable
final class NavigationPage: Identifiable {
    typealias Content = (any View)
    typealias Buttons = (any View)
    typealias ID = UUID

    let id = ID()
    var title: String
    var displayMode: ToolbarTitleDisplayMode = .automatic

    var content: () -> Content
    var buttons: () -> Buttons

    var searchable: NavigationSearchable?

    init(_ title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        buttons = { EmptyView() }
    }

    @discardableResult
    func set<T>(_ keyPath: WritableKeyPath<NavigationPage, T>, to value: T) -> T? {
        if let path = keyPath as? ReferenceWritableKeyPath<NavigationPage, T> {
            self[keyPath: path] = value
        }
        return self[keyPath: keyPath]
    }
}

extension NavigationPage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension NavigationPage: Equatable {
    static func == (lhs: NavigationPage, rhs: NavigationPage) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
