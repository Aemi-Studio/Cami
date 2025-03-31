//
//  KnowledgeBaseContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/01/25.
//

import SwiftUI

@Observable
@MainActor
final class KnowledgeBaseContext {
    private var items = KnowledgeBaseItems.allItems

    private(set) var searchResults: [KnowledgeBaseItem] = []

    var searchQuery: String = "" {
        didSet {
            Task.detached {
                await self.updateSearchResults()
            }
        }
    }

    init() {
        self.searchResults = items
    }

    private func updateSearchResults() async {
        if searchQuery == "" {
            Task { @MainActor in
                self.searchResults = items
            }
        } else {
            Task.detached(priority: .high) { [weak self, searchQuery] in
                guard let self else {
                    return
                }

                let results = await items.filter { item in
                    ![item.description, item.title].filter { string in
                        string.localizedCaseInsensitiveContains(searchQuery) ||
                            string.localizedStandardContains(searchQuery)
                    }.isEmpty
                }

                await MainActor.run { [weak self, results] in
                    self?.searchResults = results
                }
            }
        }
    }
}

extension KnowledgeBaseContext: Loggable {}

// MARK: - Knowledge Base Item

struct KnowledgeBaseItem: Identifiable {
    typealias ID = UUID

    let id = ID()

    let title: String
    let description: String
}

// MARK: - Knowledge Base Items

private enum KnowledgeBaseItems {
    static let calendar = KnowledgeBaseItem(
        title: String(localized: "knowledgebase.item.requestFullAccessToCalendar.title"),
        description: String(localized: "knowledgebase.item.requestFullAccessToCalendar.description")
    )
    static let contacts = KnowledgeBaseItem(
        title: String(localized: "knowledgebase.item.requestAccessToContacts.title"),
        description: String(localized: "knowledgebase.item.requestAccessToContacts.description")
    )
    static let reminders = KnowledgeBaseItem(
        title: String(localized: "knowledgebase.item.requestAccessToReminders.title"),
        description: String(localized: "knowledgebase.item.requestAccessToReminders.description")
    )
    static let outdatedWidgetContent = KnowledgeBaseItem(
        title: String(localized: "knowledgebase.item.outdatedWidgetContent.title"),
        description: String(localized: "knowledgebase.item.outdatedWidgetContent.description")
    )

    static let allItems = [
        calendar,
        contacts,
        reminders,
        outdatedWidgetContent
    ]
}
