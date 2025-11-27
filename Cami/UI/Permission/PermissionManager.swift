//
//  PermissionManager.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

import Observation

@MainActor
@Observable
final class PermissionManager {
    enum Permission: Sendable {
        case calendar
        case contacts
        case reminders
    }

    typealias Update = (type: Permission, status: PermissionStatus)

    private var calendarPermissionHandler: CalendarPermissionHandler?
    private var contactsPermissionHander: ContactsPermissionHandler?
    private var remindersPermissionHandler: RemindersPermissionHandler?

    private(set) var calendarStatus: PermissionStatus = .notDetermined {
        didSet {
            if oldValue != calendarStatus {
                updateContinuation.yield((.calendar, calendarStatus))
            }
        }
    }

    private(set) var contactsStatus: PermissionStatus = .notDetermined {
        didSet {
            if oldValue != contactsStatus {
                updateContinuation.yield((.contacts, contactsStatus))
            }
        }
    }

    private(set) var remindersStatus: PermissionStatus = .notDetermined {
        didSet {
            if oldValue != remindersStatus {
                updateContinuation.yield((.reminders, remindersStatus))
            }
        }
    }

    private var updateStream: AsyncStream<Update>
    private var updateContinuation: AsyncStream<Update>.Continuation

    @MainActor
    init() {
        (self.updateStream, self.updateContinuation) = AsyncStream<Update>.makeStream()

        Task {
            await loadHandlers()
            await refreshStatuses()
        }
    }

    private func loadHandlers() async {
        let calendarPermissionHandler = await CalendarPermissionHandler()

        self.calendarPermissionHandler = calendarPermissionHandler
        contactsPermissionHander = await ContactsPermissionHandler()
        remindersPermissionHandler = await RemindersPermissionHandler(
            otherHandler: calendarPermissionHandler
        )
    }

    private func refreshStatuses() async {
        calendarStatus = await calendarPermissionHandler?.checkStatus() ?? .notDetermined
        contactsStatus = await contactsPermissionHander?.checkStatus() ?? .notDetermined
        remindersStatus = await remindersPermissionHandler?.checkStatus() ?? .notDetermined
    }
}

extension PermissionManager {
    func areAllPermissionsGranted() -> Bool {
        [calendarStatus, contactsStatus, remindersStatus].allSatisfy { $0 == .authorized }
    }

    func isSomePermissionMissing() -> Bool {
        [calendarStatus, contactsStatus, remindersStatus].contains(where: { $0 != .authorized })
    }

    func isSomePermissionRestricted() -> Bool {
        [calendarStatus, contactsStatus, remindersStatus].contains(where: { $0 == .restricted })
    }

    func getPermissionUpdates() -> AsyncStream<Update> {
        updateStream
    }
}

extension PermissionManager {
    func refresh() async {
        await refreshStatuses()
    }

    func status(for permission: Permission) async -> PermissionStatus {
        guard let handler = getPermissionHandler(from: permission) else {
            return .notDetermined
        }
        return await status(for: handler)
    }

    func request(_ permission: Permission) async -> PermissionStatus {
        guard let handler = getPermissionHandler(from: permission) else {
            return .notDetermined
        }
        let newStatus = await request(handler)
        await refreshStatuses()
        return newStatus
    }
}

extension PermissionManager {
    private func status(for permission: any PermissionHandler) async -> PermissionStatus {
        await permission.checkStatus()
    }

    private func request(_ permission: any PermissionHandler) async -> PermissionStatus {
        await permission.request()
    }

    private func getPermissionHandler(from permission: Permission) -> PermissionHandler? {
        switch permission {
            case .calendar: calendarPermissionHandler
            case .contacts: contactsPermissionHander
            case .reminders: remindersPermissionHandler
            @unknown default: nil
        }
    }
}

#if DEBUG
    extension PermissionManager {
        func reset() {
            calendarStatus = .notDetermined
            contactsStatus = .notDetermined
            remindersStatus = .notDetermined
        }
    }
#endif
