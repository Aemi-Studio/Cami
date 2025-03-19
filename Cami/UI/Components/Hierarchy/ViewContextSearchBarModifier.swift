//
//  ViewContextSearchBarModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/02/25.
//

import SwiftUI
import Combine

struct ViewContextSearchBarModifier: ViewModifier {

    @Environment(\.hierarchy) private var hierarchy

    private var context: ViewContext? {
        hierarchy?.context
    }

    @Binding private(set) var query: String
    private(set) var prompt: String

    func body(content: Content) -> some View {
        if let context {
            content
                .onChange(of: context.searchQuery) { _, _ in query = context.searchQuery }
                .task(priority: .high) { @MainActor in
                    context.searchPrompt = prompt
                    context.isSearchPresented = true
                }
        } else {
            content
        }
    }
}

extension View {
    func searchable(
        query: Binding<String>,
        prompt: String = "Search..."
    ) -> some View {
        modifier(
            ViewContextSearchBarModifier(
                query: query,
                prompt: prompt
            )
        )
    }
}
