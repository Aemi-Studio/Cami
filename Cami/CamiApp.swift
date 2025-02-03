//
//  CamiApp.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

@main
struct CamiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .configureEnvironmentValues()
                .refreshWidgets()
                .environment(\.viewKind, .standard)
        }
    }
}

extension View {
    func configureEnvironmentValues() -> some View {
        environment(\.path, .shared)
            .environment(\.data, .shared)
            .environment(\.views, .shared)
            .environment(\.permissions, .shared)
            .environment(\.presentation, .shared)
            .onOpenURL(perform: Router.shared.handleURL)
    }
}
