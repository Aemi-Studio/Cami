//
//  AppNavigation.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import OSLog
import SwiftUI

@MainActor
@Observable
final class AppNavigation {

    private let logger = Logger(subsystem: "dev.music.cami", category: "AppNavigation")

    // MARK: - URL Scheme

    private static let urlScheme = "cami"
    private static let legacyScheme = "camical"

    // MARK: - Navigation State

    /// The main navigation path for push-based navigation
    var path = NavigationPath()

    /// Currently presented sheet destination
    var sheetDestination: NavigationDestination?

    /// Currently presented full screen cover destination
    var fullScreenCoverDestination: NavigationDestination?

    /// Nested navigation paths for modal presentations
    /// Used when sheets or covers need their own navigation stacks
    private var modalPaths: [NavigationDestination: NavigationPath] = [:]
    
    // MARK: - Navigation Actions
    
    /// Navigate to a destination using its configured presentation style
    func navigate(to destination: NavigationDestination) {
        switch destination.configuration.presentation {
            case .push:
                // For push navigation, simply append to the path
                path.append(destination)
                
            case .sheet:
                // Present as a sheet
                sheetDestination = destination
                // Initialize a navigation path for this modal if it needs one
                modalPaths[destination] = NavigationPath()
                
            case .fullScreenCover:
                // Present as a full screen cover
                fullScreenCoverDestination = destination
                // Initialize a navigation path for this modal if it needs one
                modalPaths[destination] = NavigationPath()
        }
    }
    
    /// Navigate back in the current context
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    /// Navigate to root of the current stack
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    /// Dismiss the currently presented sheet
    func dismissSheet() {
        if let destination = sheetDestination {
            modalPaths.removeValue(forKey: destination)
            sheetDestination = nil
        }
    }
    
    /// Dismiss the currently presented full screen cover
    func dismissFullScreenCover() {
        if let destination = fullScreenCoverDestination {
            modalPaths.removeValue(forKey: destination)
            fullScreenCoverDestination = nil
        }
    }
    
    /// Dismiss all modal presentations
    func dismissAllModals() {
        sheetDestination = nil
        fullScreenCoverDestination = nil
        modalPaths.removeAll()
    }
    
    /// Reset all navigation state to initial
    func reset() {
        path = NavigationPath()
        dismissAllModals()
    }
    
    // MARK: - Navigation Path Management for Modals
    
    /// Get the navigation path for a modal destination
    func modalPath(for destination: NavigationDestination) -> Binding<NavigationPath> {
        Binding(
            get: { [weak self] in
                self?.modalPaths[destination] ?? NavigationPath()
            },
            set: { [weak self] newPath in
                self?.modalPaths[destination] = newPath
            }
        )
    }
    
    /// Navigate within a modal's navigation stack
    func navigateInModal(_ destination: NavigationDestination, to newDestination: NavigationDestination) {
        modalPaths[destination]?.append(newDestination)
    }
    
    var isModalPresented: Bool {
        isSheetPresented || isFullScreenCoverPresented
    }
    
    var isSheetPresented: Bool {
        sheetDestination != nil
    }
    
    var isFullScreenCoverPresented: Bool {
        fullScreenCoverDestination != nil
    }
    
    var visibleDestinations: Set<NavigationDestination> {
        var destinations = Set<NavigationDestination>()

        // Add all destinations in the main path
        // Note: NavigationPath doesn't expose its contents directly,
        // so we'd need to track this separately if needed

        if let sheet = sheetDestination {
            destinations.insert(sheet)
        }

        if let cover = fullScreenCoverDestination {
            destinations.insert(cover)
        }

        return destinations
    }

    // MARK: - Deep Link Handling

    /// Handles a URL and navigates to the appropriate destination
    /// - Parameter url: The URL to handle
    /// - Returns: Whether the URL was successfully handled
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        guard let destination = destination(from: url) else {
            logger.warning("Unable to handle URL: \(url.absoluteString)")
            return false
        }

        // Dismiss any existing modals first
        dismissAllModals()

        // Navigate to the destination
        navigate(to: destination)

        logger.info("Handled URL: \(url.absoluteString) -> \(destination.id)")
        return true
    }

    /// Converts a URL to a NavigationDestination
    private func destination(from url: URL) -> NavigationDestination? {
        guard url.scheme == Self.urlScheme || url.scheme == Self.legacyScheme else {
            return nil
        }

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
            let date = dateFromURL(url)
            switch kindString {
            case "event":
                return .createEvent(date: date)
            case "reminder":
                return .createReminder(date: date)
            default:
                return .createEvent(date: nil)
            }

        case "settings":
            return .settings

        case "calendars":
            return .allCalendarsSelection

        case "onboarding":
            return .onboarding

        case "permissions":
            return .permissions

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
