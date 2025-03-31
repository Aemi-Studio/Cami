//
//  AppState.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

@Observable
final class AppState: Equatable, Loggable {
    private(set) var date: Date {
        didSet {
            dayContext = .init(for: date)
        }
    }

    private(set) var dayContext: SingleDayContext

    init(date: Date = .now) {
        self.date = date
        self.dayContext = .init(for: date)
        log.info("AppState Initialization")
    }

    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.date == rhs.date
    }
}

extension EnvironmentValues {
    @Entry var appState: AppState?
}
