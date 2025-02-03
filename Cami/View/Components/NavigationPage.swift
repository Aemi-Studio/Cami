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
        self.buttons = { EmptyView() }
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

struct NavigationPageSetModifier<T>: ViewModifier {

    @Environment(\.navigation) private var navigation

    let path: WritableKeyPath<NavigationPage, T>
    let value: T

    func body(content: Content) -> some View {
        content
            .task { navigation?.current?.set(path, to: value) }
    }
}

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
        isPresented: Binding<Bool>,
        prompt: String
    ) -> some View {
        self.setNavigationPage(
            \.searchable,
            to: NavigationSearchable(
                query: query,
                prompt: prompt
            )
        )
    }

    func setNavigationPage<T>(_ path: WritableKeyPath<NavigationPage, T>, to value: T) -> some View {
        modifier(NavigationPageSetModifier(path: path, value: value))
    }

    @ViewBuilder
    func buttons<Content>(@ButtonBuilder content: @escaping () -> Content) -> some View where Content: View {
        self.setNavigationPage(\.buttons, to: content)
    }
}
