//
//  ReminderHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import EventKit
import OSLog

struct ReminderHelper {

    static let store: EKEventStore = .init()

    public static func requestAccess() async -> PermissionSet {
        do {
            return try await Self.store.requestFullAccessToReminders()
                ? .reminders
                : .restrictedReminders
        } catch {
            Logger.perms.error("\(String(describing: error))")
        }
        Logger.perms.error("ReminderHelper() -> .none")
        return .none
    }

    public static func requestAccess(
        callback: @escaping (PermissionSet) -> Void
    ) {
        Self.store.requestFullAccessToReminders { result, error in
            if error != nil {
                Logger.perms.error("\(String(describing: error))")
                callback(.none)
            } else {
                Logger.perms.error("ReminderHelper() -> \(result.description)")
                callback(result ? .reminders : .none)
            }
        }
    }

}
