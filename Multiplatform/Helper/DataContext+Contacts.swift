//
//  DataContext+Contacts.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import Contacts
import Foundation

// MARK: - Contacts

extension DataContext {
    /// Resolve contact birthdate from a specified contact identifier using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - identifier: The contact identifier `String` to resolve the unified contact from.
    ///
    /// - Returns: The birthdate of the contact.
    ///
    func resolveBirthdate(
        _ identifier: String
    ) -> DateComponents? {
        let fetchedBirthdate: DateComponents?
        do {
            fetchedBirthdate = try contactStore.unifiedContact(
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
    func resolveContactName(_ identifier: String) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try contactStore.unifiedContact(
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
        ].first(where: { string in !string.isEmpty }) ?? ""
    }

    /// Resolve contact name from a specified contact predicate using `unifiedContact`.
    ///
    /// - Parameters:
    ///     - predicate: The contact predicate `NSPredicate` to resolve the unified contact from.
    ///
    /// - Returns: The name of the contact. Preferably the nickname. If a nickname isn't provided,
    /// it fallbacks to the given name (first name).
    ///
    func resolveContactName(
        _ predicate: NSPredicate
    ) -> String {
        let fetchedContact: CNContact?
        do {
            fetchedContact = try contactStore.unifiedContacts(
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
        ].first(where: { string in !string.isEmpty }) ?? ""
    }
}
