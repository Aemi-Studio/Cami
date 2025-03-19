//
//  Hierarchy.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI

@Observable
@MainActor
final class Hierarchy {

    private(set) var context: Context

    init(_ context: Context) {
        self.context = context
    }

    func last() -> Context {
        var current = context
        while let child = current.child {
            current = child
        }
        return current
    }

    func forward(to context: Context) {
        self.context = self.context.navigate(to: context)
    }

    func forward(@ViewBuilder content: @escaping () -> Context.Content) {
        context = context.navigate(to: content)
    }

    func backward() {
        if let parent = context.dismiss() {
            context = parent
        }
    }

    func move(to context: Context) {
        self.context = context.shed()
    }

}

extension EnvironmentValues {
    @Entry var hierarchy: Hierarchy?
}
