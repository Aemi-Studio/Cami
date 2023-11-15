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
                .onAppear {
                    Task {
                        await CalendarHandler.request()
                    }
                    Task {
                        await ContactHelper.request()
                    }
                }
        }
    }
}
