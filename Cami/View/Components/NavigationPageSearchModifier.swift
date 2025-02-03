//
//  NavigationPageSearchModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/02/25.
//

import SwiftUI

struct NavigationPageSearchModifier<T>: ViewModifier {
    @Environment(\.navigation) private var navigation

    @Binding var query: String
    @Binding var isPresented: Bool
    let prompt: String

    func body(content: Content) -> some View {
        if let navigation {
            content
                .task { navigation.current?.set(\.searchable, to: NavigationSearchable(query: $query, prompt: prompt)) }
                .onChange(of: isPresented) { _, newValue in
                    if navigation.isSearchFocused != newValue {
                        navigation.isSearchFocused = newValue
                    }
                }
                .onChange(of: navigation.isSearchFocused) { _, newValue in
                    if isPresented != newValue {
                        isPresented = newValue
                    }
                }
        }
    }
}

extension View {
    func searchable(
        query: Binding<String>,
        isPresented _: Binding<Bool>,
        prompt: String
    ) -> some View {
        setNavigationPage(
            \.searchable,
            to: NavigationSearchable(
                query: query,
                prompt: prompt
            )
        )
    }
}
