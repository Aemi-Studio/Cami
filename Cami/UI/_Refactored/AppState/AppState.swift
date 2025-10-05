//
//  AppState.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

@MainActor
@Observable
final class AppState: Loggable {
    private(set) var date: Date

    var dayContext: SingleDayContext {
        SingleDayContext(for: date)
    }
    
    /// Navigation state for the app
    let navigation = AppNavigation()
    let storage = AppStorageManager()

    init(date: Date = .now) {
        self.date = date
        
        Task { @MainActor [weak self] in
            await self?.initialize()
        }
    }
    
    private func initialize() async {
        if !hasCompletedOnboarding {
            navigation.performComplexFlow(.onboarding)
        }
    }
}
