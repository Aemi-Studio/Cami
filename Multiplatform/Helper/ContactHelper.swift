//
//  ContactHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import Contacts

struct ContactHelper {

    /// Request access to contacts data in an asynchronous way.
    ///
    /// - Parameters:
    ///     - store: The `CNContactStore` to use to fetch information. Defaults to `CamiHelper.contactStore`.
    ///
    /// - Returns: The access status as an `AuthenticationSet` object.
    ///
    public static func requestAccess(
        store: CNContactStore = CamiHelper.contactStore
    ) async -> AuthSet {
        do {
            return try await store.requestAccess(
                for: .contacts
            ) ? .contacts : .restrictedContacts
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
            return .restrictedContacts
        }
    }

    /// Request access to contacts data in a synchronous way, providing a callback.
    ///
    /// - Parameters:
    ///     - store: The `CNContactStore` to use to fetch information. Defaults to `CamiHelper.contactStore`.
    ///     - callback: The callback function to interact with the access status.
    ///     The status is passed to the callback as an `AuthenticationSet` object.
    ///
    public static func requestAccess(
        store: CNContactStore = CamiHelper.contactStore,
        _ callback: @escaping (AuthSet) -> Void
    ) {
        store.requestAccess(for: .contacts) { result, error in
            if error != nil {
                #if DEBUG
                print(error!.localizedDescription)
                #endif
                callback(.restrictedContacts)
            } else {
                callback(result ? .contacts : .restrictedContacts)
            }
        }
    }

    /// Resolve contact birthdate from a specified contact identifier using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - store: The `CNContactStore` to use to fetch information. Defaults to `CamiHelper.contactStore`.
    ///     - identifier: The contact identifier `String` to resolve the unified contact from.
    ///
    /// - Returns: The birthdate of the contact.
    ///
    public static func resolveBirthdate(
        store: CNContactStore = CamiHelper.contactStore,
        _ identifier: String
    ) -> DateComponents? {
        let fetchedBirthdate: DateComponents?
        do {
            fetchedBirthdate = try store.unifiedContact(withIdentifier: identifier, keysToFetch: [CNContactBirthdayKey as CNKeyDescriptor]).birthday
        } catch {
            print(
                error.localizedDescription
            )
            fetchedBirthdate = nil
        }
        return fetchedBirthdate
    }

    /// Resolve contact name from a specified contact identifier using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - store: The `CNContactStore` to use to fetch information. Defaults to `CamiHelper.contactStore`.
    ///     - identifier: The contact identifier `String` to resolve the unified contact from.
    ///
    /// - Returns: The name of the contact. Preferably the nickname. If a nickname isn't provided,
    /// it fallbacks to the given name (first name).
    ///
    public static func resolveContactName(
        store: CNContactStore = CamiHelper.contactStore,
        _ identifier: String
    ) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try store.unifiedContact(
                withIdentifier: identifier,
                keysToFetch: [
                    CNContactNicknameKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor
                ]
            )
        } catch {
            print(
                error.localizedDescription
            )
            fetchedContact = nil
        }
        return [
            fetchedContact?.nickname ?? "",
            fetchedContact?.givenName ?? ""
        ].first(where: {string in !string.isEmpty}) ?? ""
    }

    /// Resolve contact name from a specified contact predicate using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - store: The `CNContactStore` to use to fetch information. Defaults to `CamiHelper.contactStore`.
    ///     - predicate: The contact predicate `NSPredicate` to resolve the unified contact from.
    ///
    /// - Returns: The name of the contact. Preferably the nickname. If a nickname isn't provided,
    /// it fallbacks to the given name (first name).
    ///
    public static func resolveContactName(
        store: CNContactStore = CamiHelper.contactStore,
        _ predicate: NSPredicate
    ) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try store.unifiedContacts(
                matching: predicate,
                keysToFetch: [
                    CNContactNicknameKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor
                ]
            ).first
        } catch {
            print(
                error.localizedDescription
            )
            fetchedContact = nil
        }
        return [
            fetchedContact?.nickname ?? "",
            fetchedContact?.givenName ?? ""
        ].first(where: {string in !string.isEmpty}) ?? ""
    }

}
