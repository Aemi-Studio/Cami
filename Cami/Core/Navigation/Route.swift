//
//  Route.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import EventKit
import Foundation

/// Defines all navigable destinations in the app.
///
/// Routes are type-safe representations of app screens that can be:
/// - Pushed onto a navigation stack
/// - Presented as sheets
/// - Presented as full-screen covers
enum Route: Hashable, Identifiable, Sendable {
    // MARK: - Main Navigation

    /// The main day view
    case main

    /// Settings screen
    case settings

    // MARK: - Calendar Management

    /// Calendar selection for a specific item type
    case calendarSelection(kind: CalendarItemKind)

    /// All calendars selection (combined events and reminders)
    case allCalendarsSelection

    // MARK: - Item Details

    /// Event detail view
    case eventDetail(identifier: String)

    /// Reminder detail view
    case reminderDetail(identifier: String)

    // MARK: - Creation

    /// Create a new calendar item
    case createItem(kind: CalendarItemKind, date: Date?)

    /// Create a new event
    case createEvent(date: Date?)

    /// Create a new reminder
    case createReminder(date: Date?)

    // MARK: - Onboarding & Permissions

    /// Onboarding flow
    case onboarding

    /// Permissions request screen
    case permissions

    /// Specific permission request
    case permissionRequest(PermissionKind)

    // MARK: - Utility

    /// About screen
    case about

    /// Privacy policy
    case privacyPolicy

    // MARK: - Identifiable

    var id: String {
        switch self {
        case .main:
            return "main"
        case .settings:
            return "settings"
        case .calendarSelection(let kind):
            return "calendarSelection-\(kind)"
        case .allCalendarsSelection:
            return "allCalendarsSelection"
        case .eventDetail(let identifier):
            return "eventDetail-\(identifier)"
        case .reminderDetail(let identifier):
            return "reminderDetail-\(identifier)"
        case .createItem(let kind, _):
            return "createItem-\(kind)"
        case .createEvent:
            return "createEvent"
        case .createReminder:
            return "createReminder"
        case .onboarding:
            return "onboarding"
        case .permissions:
            return "permissions"
        case .permissionRequest(let kind):
            return "permissionRequest-\(kind)"
        case .about:
            return "about"
        case .privacyPolicy:
            return "privacyPolicy"
        }
    }
}

// MARK: - Supporting Types

/// Typealias to use existing CalendarItem.Kind
typealias CalendarItemKind = CalendarItem.Kind

/// Types of permissions the app can request
enum PermissionKind: String, Hashable, Sendable, CaseIterable {
    case calendar
    case reminders
    case contacts

    var localizedName: String {
        switch self {
        case .calendar:
            return String(localized: "permissionKind.calendar")
        case .reminders:
            return String(localized: "permissionKind.reminders")
        case .contacts:
            return String(localized: "permissionKind.contacts")
        }
    }
}

// MARK: - Presentation Style

/// How a route should be presented
enum PresentationStyle: Sendable {
    /// Push onto navigation stack
    case push

    /// Present as sheet
    case sheet

    /// Present as full-screen cover
    case fullScreenCover
}
