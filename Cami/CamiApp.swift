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
    private var model: ViewModel = .shared

    @State
    private var perms: PermissionModel = .shared

    var body: some Scene {
        WindowGroup {
            ContentView(
                model: model,
                perms: perms
            )
            .environment(model)
            .environmentObject(model)
            .environment(perms)
            .environmentObject(perms)
        }
    }
}
