//
//  StoreError.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/11/25.
//

import Foundation

/// Errors that can occur in store operations
enum StoreError: LocalizedError, Sendable {
    /// Failed to load data from EventKit
    case loadFailed(underlying: Error?)

    /// No access to calendar data
    case noAccess

    /// Data is unavailable
    case dataUnavailable

    /// Cache operation failed
    case cacheFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed(let underlying):
            if let underlying {
                return "Failed to load data: \(underlying.localizedDescription)"
            }
            return "Failed to load calendar data"

        case .noAccess:
            return "Calendar access is required to display events and reminders"

        case .dataUnavailable:
            return "Calendar data is temporarily unavailable"

        case .cacheFailed:
            return "Failed to update calendar cache"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .loadFailed:
            return "Try refreshing or check your internet connection"

        case .noAccess:
            return "Please grant calendar access in Settings"

        case .dataUnavailable:
            return "Pull down to refresh"

        case .cacheFailed:
            return "Try again later"
        }
    }
}
