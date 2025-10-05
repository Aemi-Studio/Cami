//
//  CalendarPermissionHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

import EventKit

struct CalendarPermissionHandler: EventPermissionHandler {
    let store: EKEventStore

    init() {
        self.store = EKEventStore()
    }

    init(otherHandler: EventPermissionHandler) {
        self.store = otherHandler.store
    }

    var status: PermissionStatus {
        get async {
            await checkStatus()
        }
    }

    func checkStatus() async -> PermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied, .writeOnly: .denied
            case .authorized, .fullAccess: .authorized
            @unknown default: .denied
        }
    }

    func request() async -> PermissionStatus {
        let status = await status

        guard status == .notDetermined else {
            return status
        }

        do {
            return try await store.requestFullAccessToEvents() ? .authorized : .denied
        } catch {
            return .denied
        }
    }
}
