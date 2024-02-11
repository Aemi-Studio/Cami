//
//  ReminderHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import EventKit

struct ReminderHelper {

    public static func requestAccess() async -> PermissionSet {
        do {
            return try await  EventHelper.store.requestFullAccessToReminders()
                ? .reminders
                : .restrictedReminders
        } catch {
            print(error.localizedDescription)
        }
        return .none
    }

    public static func requestAccess(
        callback: @escaping (PermissionSet) -> Void
    ) {
        EventHelper.store.requestFullAccessToReminders { result, error in
            if error != nil {
                callback(.none)
            } else {
                callback(result ? .reminders : .none)
            }
        }
    }

}
