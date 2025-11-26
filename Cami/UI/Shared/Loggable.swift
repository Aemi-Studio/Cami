//
//  Loggable.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import OSLog

public protocol Loggable {}

public extension Loggable {
    static var logger: Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "studio.aemi.Cami",
            category: String(describing: Self.self)
        )
    }

    var logger: Logger {
        Self.logger
    }
}
