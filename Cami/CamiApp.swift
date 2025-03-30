//
//  CamiApp.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

@main
struct CamiApp: App {
    @State private var appState = AppState(date: .now)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appState, appState)
                .modifier(AppEnvironment())
                .refreshWidgets()
                .setupModals()
                .environment(\.viewKind, .standard)
        }
    }
}

struct AppEnvironment: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.data, .shared)
            .environment(\.modal, .shared)
            .environment(\.views, .shared)
            .environment(\.permissions, .shared)
            .environment(\.presentation, .shared)
            .environment(\.locale, .prefered)
            .onOpenURL(perform: Router.shared.handleURL)
    }
}
