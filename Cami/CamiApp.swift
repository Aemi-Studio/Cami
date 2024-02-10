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
    private var permissions: PermissionModel = .shared

    var body: some Scene {
        WindowGroup {
            ContentView(
                model: model,
                perms: permissions
            )
            .environment(model)
            .environmentObject(model)
            .environment(permissions)
            .environmentObject(permissions)
        }
    }
}
