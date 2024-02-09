//
//  CamiApp.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

@main
struct CamiApp: App {

    @State
    private var model: ViewModel = .init(for: Date.now)

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .environment(model)
                .environmentObject(model)
        }
    }
}
