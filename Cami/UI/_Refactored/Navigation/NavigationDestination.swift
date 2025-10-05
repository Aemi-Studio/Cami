//
//  NavigationDestination.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

enum NavigationDestination: Hashable, Codable, Equatable, Navigable {
    var id: String { configuration.id }

    // MARK: - Root
    case main
    
    // MARK: - Onboarding
    case onboarding
    case onboardingPermissionsCalendar
    case onboardingPermissionsContacts
    case onboardingPermissionsReminders
    case onboardingCompletion
    
    // MARK: - Settings & Configuration
    case settings
    case permissions
    case widgetSettings
    #if DEBUG
    case developer
    #endif
    
    // MARK: - Information & Help
    case knowledgeBase
    case widgets
}

extension NavigationDestination {
    var configuration: NavigationConfiguration<Self> {
        switch self {
            // Root - no parent, always the base
            case .main:
                .init(id: "main", presentation: .push)
            
            // Onboarding - presented as sheet, no parent
            case .onboarding:
                .init(id: "onboarding", presentation: .sheet)
            case .onboardingPermissionsCalendar:
                .init(id: "onboarding.permissions.calendar", parent: .onboarding, presentation: .push)
            case .onboardingPermissionsContacts:
                .init(id: "onboarding.permissions.contacts", parent: .onboarding, presentation: .push)
            case .onboardingPermissionsReminders:
                .init(id: "onboarding.permissions.reminders", parent: .onboarding, presentation: .push)
            case .onboardingCompletion:
                .init(id: "onboarding.completion", parent: .onboarding, presentation: .push)
            
            // Settings - presented as sheet, no parent
            case .settings:
                .init(id: "settings", presentation: .sheet)
            
            // Permissions - can be pushed from settings
            case .permissions:
                .init(id: "permissions", parent: .settings, presentation: .push)
            
            // Widget Settings - pushed from settings
            case .widgetSettings:
                .init(id: "widgetSettings", parent: .settings, presentation: .push)
            
            #if DEBUG
            // Developer - pushed from settings (debug only)
            case .developer:
                .init(id: "developer", parent: .settings, presentation: .push)
            #endif
            
            // Knowledge Base - pushed from settings
            case .knowledgeBase:
                .init(id: "knowledgeBase", parent: .settings, presentation: .push)
            
            // Widgets - presented as sheet for widget preview, no parent
            case .widgets:
                .init(id: "widgets", presentation: .sheet)
        }
    }
}
