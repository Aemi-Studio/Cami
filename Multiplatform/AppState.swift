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
    private(set) var date: Date {
        didSet {
            dayContext = .init(for: date)
        }
    }

    private(set) var dayContext: SingleDayContext
    
    /// Navigation state for the app
    let navigation = AppNavigation()

    init(date: Date = .now) {
        self.date = date
        self.dayContext = .init(for: date)
        logger.info("AppState Initialization")
    }
}

extension EnvironmentValues {
    @Entry var appState: AppState?
}
