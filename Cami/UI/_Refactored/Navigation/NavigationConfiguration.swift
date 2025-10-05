//
//  NavigationConfiguration.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

struct NavigationConfiguration<Item>: Identifiable, Hashable, Equatable, Sendable, Codable where Item: Navigable {
    private(set) var id: String
    private(set) var parent: Item?
    private(set) var presentation: NavigationPresentation = .push
}

extension NavigationConfiguration: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.id = value
        self.parent = nil
        self.presentation = .push
    }
}
