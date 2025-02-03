//
//  NavigationPageSetModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/02/25.
//

import SwiftUI

struct NavigationPageSetModifier<T>: ViewModifier {
    @Environment(\.navigation) private var navigation

    let path: WritableKeyPath<NavigationPage, T>
    let value: T

    func body(content: Content) -> some View {
        content
            .task { navigation?.current?.set(path, to: value) }
    }
}

extension View {
    func setNavigationPage<T>(_ path: WritableKeyPath<NavigationPage, T>, to value: T) -> some View {
        modifier(NavigationPageSetModifier(path: path, value: value))
    }
}
