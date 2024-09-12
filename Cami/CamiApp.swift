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
            ContentView()
                .onOpenURL(perform: Router.shared.handleURL)
                .environment(model)
                .environment(perms)
        }
    }
}
