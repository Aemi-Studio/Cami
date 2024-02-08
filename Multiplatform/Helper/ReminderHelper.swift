//
//  ReminderHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import EventKit

struct ReminderHelper {

    public static func requestAccess(
        store: EKEventStore = CamiHelper.eventStore
    ) async -> AuthSet {
        do {
            return try await  store.requestFullAccessToReminders() ? .reminders : .restrictedReminders
        } catch {
            print(error.localizedDescription)
        }
        return .none
    }

    public static func requestAccess(
        store: EKEventStore = CamiHelper.eventStore,
        callback: @escaping (AuthSet) -> Void
    ) {
        store.requestFullAccessToReminders { result, error in
            if error != nil {
                #if DEBUG
                print(error!.localizedDescription)
                #endif
                callback(.none)
            } else {
                callback(result ? .reminders : .none)
            }
        }
    }

}
