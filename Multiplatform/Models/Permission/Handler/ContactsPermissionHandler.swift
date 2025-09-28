//
//  ContactsPermissionHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//


import Contacts

struct ContactsPermissionHandler: PermissionHandler {
    private let store = CNContactStore()

    var status: PermissionStatus {
        get async {
            await checkStatus()
        }
    }
    
    func checkStatus() async -> PermissionStatus {
        switch CNContactStore.authorizationStatus(for: .contacts) {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied: .denied
                // We set it to .authorized for limited because user expects that it should work with a subset of contacts.
            case .authorized, .limited: .authorized
            @unknown default: .denied
        }
    }

    func request() async -> PermissionStatus {
        let status = await status
        
        guard status == .notDetermined else { return status }

        do {
            return try await store.requestAccess(for: .contacts) ? .authorized : .denied
        } catch {
            logger.error("Failed to request contacts access: \(error.localizedDescription)")
            return .denied
        }
    }
}
