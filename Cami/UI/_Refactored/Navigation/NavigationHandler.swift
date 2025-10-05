//
//  NavigationHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

struct NavigationHandler: ViewModifier {
    @Environment(AppNavigation.self) private var navigation
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                handleDeepLink(url)
            }
    }
    
    private func handleDeepLink(_ url: URL) {}
}

extension View {
    func withNavigationHandling() -> some View {
        modifier(NavigationHandler())
    }
}
