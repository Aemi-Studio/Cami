//
//  Realm.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI

struct ViewLink: View {
    typealias Content = (any View)
    typealias Label = (any View)

    @Environment(\.hierarchy) var hierarchy

    private(set) var context: ViewContext?
    private(set) var content: (() -> Content)?
    let label: () -> Label

    init(
        @ViewBuilder content: @escaping () -> some View,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
    }

    init(
        context: ViewContext,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.context = context
        self.label = label
    }

    var body: some View {
        Button {
            Task {
                if let context {
                    hierarchy?.move(to: context)
                } else if let content {
                    hierarchy?.forward(content: content)
                }
            }
        } label: {
            AnyView(label())
        }
        .disabled(hierarchy == nil)
    }
}
