//
//  NavigationHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

struct NavigationHandler: ViewModifier {
    @Environment(AppNavigation.self) private var navigation: AppNavigation?

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                navigation?.handleURL(url)
            }
    }
}

extension View {
    func withNavigationHandling() -> some View {
        modifier(NavigationHandler())
    }
}
