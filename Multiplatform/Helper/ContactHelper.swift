//
//  ContactHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import Contacts
import OSLog

struct ContactHelper: Loggable {

    static let store: CNContactStore = .init()

    /// Request access to contacts data in an asynchronous way.
    ///
    ///
    /// - Returns: The access status as an `AuthorizationSet` object.
    ///
    public static func requestAccess() async -> PermissionSet {
        do {
            let result = try await Self.store.requestAccess(for: .contacts)
            log.error("ContactHelper -> \(String(describing: result))")
            return result ? .contacts : .restrictedContacts
        } catch {
            log.error("\(String(describing: error))")
            return .restrictedContacts
        }
    }

    /// Request access to contacts data in a synchronous way, providing a callback.
    ///
    /// - Parameters:
    ///     - callback: The callback function to interact with the access status.
    ///     The status is passed to the callback as an `AuthorizationSet` object.
    ///
    public static func requestAccess(
        _ callback: @escaping (PermissionSet) -> Void
    ) {
        Self.store.requestAccess(for: .contacts) { result, error in
            if error != nil {
                log.error("\(String(describing: error))")
                callback(.restrictedContacts)
            } else {
                log.error("ContactHelper -> \(String(describing: result))")
                callback(result ? .contacts : .restrictedContacts)
            }
        }
    }

    /// Resolve contact birthdate from a specified contact identifier using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - identifier: The contact identifier `String` to resolve the unified contact from.
    ///
    /// - Returns: The birthdate of the contact.
    ///
    public static func resolveBirthdate(
        _ identifier: String
    ) -> DateComponents? {
        let fetchedBirthdate: DateComponents?
        do {
            fetchedBirthdate = try Self.store.unifiedContact(
                withIdentifier: identifier,
                keysToFetch: [CNContactBirthdayKey as CNKeyDescriptor]
            ).birthday
        } catch {
            log.error("\(String(describing: error))")
            fetchedBirthdate = nil
        }
        return fetchedBirthdate
    }

    /// Resolve contact name from a specified contact identifier using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - identifier: The contact identifier `String` to resolve the unified contact from.
    ///
    /// - Returns: The name of the contact. Preferably the nickname. If a nickname isn't provided,
    /// it fallbacks to the given name (first name).
    ///
    public static func resolveContactName(_ identifier: String) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try Self.store.unifiedContact(
                withIdentifier: identifier,
                keysToFetch: [
                    CNContactNicknameKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor
                ]
            )
        } catch {
            log.error("\(String(describing: error))")
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
    ///     - predicate: The contact predicate `NSPredicate` to resolve the unified contact from.
    ///
    /// - Returns: The name of the contact. Preferably the nickname. If a nickname isn't provided,
    /// it fallbacks to the given name (first name).
    ///
    public static func resolveContactName(
        _ predicate: NSPredicate
    ) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try Self.store.unifiedContacts(
                matching: predicate,
                keysToFetch: [
                    CNContactNicknameKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor
                ]
            ).first
        } catch {
            log.error("\(String(describing: error))")
            fetchedContact = nil
        }
        return [
            fetchedContact?.nickname ?? "",
            fetchedContact?.givenName ?? ""
        ].first(where: {string in !string.isEmpty}) ?? ""
    }

}
