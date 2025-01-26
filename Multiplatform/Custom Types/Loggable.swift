//
//  Loggable.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import OSLog

public protocol Loggable {
    var log: Logger { get }
}

public extension Loggable {
    static var log: Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: String(describing: Self.self))
    }
    var log: Logger {
        Self.log
    }
}
