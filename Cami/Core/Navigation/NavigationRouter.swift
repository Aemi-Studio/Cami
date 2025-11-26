//
//  NavigationRouter.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import Foundation
import OSLog
import SwiftUI

/// Centralized navigation state manager.
///
/// NavigationRouter provides a single source of truth for:
/// - Navigation stack (push/pop)
/// - Sheet presentations
/// - Full-screen cover presentations
/// - Deep link handling
@Observable
@MainActor
final class NavigationRouter {
    static let shared = NavigationRouter()

    private let logger = Logger(subsystem: "dev.music.cami", category: "NavigationRouter")

    // MARK: - Navigation State

    /// The navigation path for stack-based navigation
    var path: [Route] = []

    /// Currently presented sheet route
    var sheet: Route?

    /// Currently presented full-screen cover route
    var fullScreenCover: Route?

    /// Whether a sheet is currently presented
    var isSheetPresented: Bool {
        sheet != nil
    }

    /// Whether a full-screen cover is currently presented
    var isFullScreenCoverPresented: Bool {
        fullScreenCover != nil
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Stack Navigation

    /// Pushes a route onto the navigation stack
    func push(_ route: Route) {
        path.append(route)
        logger.debug("Pushed route: \(route.id)")
    }

    /// Pops the top route from the navigation stack
    func pop() {
        guard !path.isEmpty else { return }
        let popped = path.removeLast()
        logger.debug("Popped route: \(popped.id)")
    }

    /// Pops to the root of the navigation stack
    func popToRoot() {
        path.removeAll()
        logger.debug("Popped to root")
    }

    /// Pops to a specific route in the stack
    func popTo(_ route: Route) {
        guard let index = path.firstIndex(of: route) else { return }
        path = Array(path.prefix(through: index))
        logger.debug("Popped to route: \(route.id)")
    }

    /// Replaces the entire navigation stack with a single route
    func replaceStack(with route: Route) {
        path = [route]
        logger.debug("Replaced stack with route: \(route.id)")
    }

    // MARK: - Modal Presentation

    /// Presents a route using the specified style
    func present(_ route: Route, style: PresentationStyle = .sheet) {
        switch style {
        case .push:
            push(route)
        case .sheet:
            presentSheet(route)
        case .fullScreenCover:
            presentFullScreenCover(route)
        }
    }

    /// Presents a route as a sheet
    func presentSheet(_ route: Route) {
        sheet = route
        logger.debug("Presented sheet: \(route.id)")
    }

    /// Presents a route as a full-screen cover
    func presentFullScreenCover(_ route: Route) {
        fullScreenCover = route
        logger.debug("Presented full-screen cover: \(route.id)")
    }

    /// Dismisses the current sheet
    func dismissSheet() {
        guard let currentSheet = sheet else { return }
        sheet = nil
        logger.debug("Dismissed sheet: \(currentSheet.id)")
    }

    /// Dismisses the current full-screen cover
    func dismissFullScreenCover() {
        guard let currentCover = fullScreenCover else { return }
        fullScreenCover = nil
        logger.debug("Dismissed full-screen cover: \(currentCover.id)")
    }

    /// Dismisses any presented modal (sheet or full-screen cover)
    func dismiss() {
        if sheet != nil {
            dismissSheet()
        } else if fullScreenCover != nil {
            dismissFullScreenCover()
        }
    }

    /// Dismisses all modals and pops to root
    func dismissAll() {
        sheet = nil
        fullScreenCover = nil
        popToRoot()
        logger.debug("Dismissed all navigation state")
    }

    // MARK: - Deep Link Handling

    /// Handles a URL and navigates to the appropriate route
    /// - Parameter url: The URL to handle
    /// - Returns: Whether the URL was successfully handled
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        guard let route = route(from: url) else {
            logger.warning("Unable to handle URL: \(url.absoluteString)")
            return false
        }

        // Dismiss any existing modals first
        dismiss()

        // Navigate to the route
        switch route {
        case .eventDetail, .reminderDetail:
            push(route)
        case .createEvent, .createReminder, .createItem:
            presentSheet(route)
        case .settings, .about:
            presentSheet(route)
        case .onboarding, .permissions:
            presentFullScreenCover(route)
        default:
            push(route)
        }

        logger.info("Handled URL: \(url.absoluteString) -> \(route.id)")
        return true
    }

    /// Converts a URL to a Route
    private func route(from url: URL) -> Route? {
        guard url.scheme == "cami" else { return nil }

        let host = url.host()
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "event":
            if let identifier = pathComponents.first {
                return .eventDetail(identifier: identifier)
            }
        case "reminder":
            if let identifier = pathComponents.first {
                return .reminderDetail(identifier: identifier)
            }
        case "create":
            let kindString = pathComponents.first
            switch kindString {
            case "event":
                return .createEvent(date: dateFromURL(url))
            case "reminder":
                return .createReminder(date: dateFromURL(url))
            default:
                return .createItem(kind: .event, date: nil)
            }
        case "settings":
            return .settings
        case "calendars":
            return .allCalendarsSelection
        case "onboarding":
            return .onboarding
        default:
            return nil
        }

        return nil
    }

    /// Extracts a date from URL query parameters
    private func dateFromURL(_ url: URL) -> Date? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let dateString = queryItems.first(where: { $0.name == "date" })?.value
        else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}

// MARK: - SwiftUI Bindings

extension NavigationRouter {
    /// Binding for sheet presentation
    var sheetBinding: Binding<Route?> {
        Binding(
            get: { self.sheet },
            set: { self.sheet = $0 }
        )
    }

    /// Binding for full-screen cover presentation
    var fullScreenCoverBinding: Binding<Route?> {
        Binding(
            get: { self.fullScreenCover },
            set: { self.fullScreenCover = $0 }
        )
    }

    /// Binding for navigation path
    var pathBinding: Binding<[Route]> {
        Binding(
            get: { self.path },
            set: { self.path = $0 }
        )
    }
}

// MARK: - Convenience Methods

extension NavigationRouter {
    /// Navigates to event details
    func showEventDetail(_ event: EKEvent) {
        guard let identifier = event.eventIdentifier else { return }
        push(.eventDetail(identifier: identifier))
    }

    /// Navigates to reminder details
    func showReminderDetail(_ reminder: EKReminder) {
        push(.reminderDetail(identifier: reminder.calendarItemIdentifier))
    }

    /// Shows the create event sheet
    func showCreateEvent(for date: Date? = nil) {
        presentSheet(.createEvent(date: date))
    }

    /// Shows the create reminder sheet
    func showCreateReminder(for date: Date? = nil) {
        presentSheet(.createReminder(date: date))
    }

    /// Shows settings
    func showSettings() {
        presentSheet(.settings)
    }

    /// Shows calendar selection
    func showCalendarSelection(for kind: CalendarItemKind? = nil) {
        if let kind {
            presentSheet(.calendarSelection(kind: kind))
        } else {
            presentSheet(.allCalendarsSelection)
        }
    }

    /// Shows onboarding flow
    func showOnboarding() {
        presentFullScreenCover(.onboarding)
    }
}

// MARK: - EKEvent Import

import EventKit
