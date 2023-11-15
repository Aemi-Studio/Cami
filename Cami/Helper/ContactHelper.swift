//
//  ContactHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import Contacts


final class ContactHelper {

    static let store: CNContactStore = CNContactStore()

    public static func request() async -> Bool {
        let store: CNContactStore = self.store
        do {
            return try await store.requestAccess(
                for: .contacts
            )
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
            return false
        }
    }
    
    public static func getNameFromContactIdentifier(
        _ birthdayContactIdentifier: String
    ) -> String {
        
        let store: CNContactStore = self.store
        let fetchedContact: CNContact?

        do {
            fetchedContact = try store.unifiedContact(
                withIdentifier: birthdayContactIdentifier,
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
            fetchedContact?.givenName ?? "",
        ].first(where: {string in !string.isEmpty}) ?? ""
    }
}
