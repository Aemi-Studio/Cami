//
//  AppNavigation+Views.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

extension AppNavigation {
    /// Returns the appropriate view for a given navigation destination
    @ViewBuilder
    func view(for destination: NavigationDestination) -> some View {
        Group {
            switch destination {
                case .main:
                    EmptyView() // Main view is handled by AppView
                    
                case .onboarding:
                    OnboardingIntroView()
                case .onboardingPermissionsCalendar:
                    OnboardingPermissionStepView(permission: .calendar)
                case .onboardingPermissionsContacts:
                    OnboardingPermissionStepView(permission: .contacts)
                case .onboardingPermissionsReminders:
                    OnboardingPermissionStepView(permission: .reminders)
                case .onboardingCompletion:
                    OnboardingCompletionView()
                    
                case .settings:
                    CustomSettingsView()
                    
                case .permissions:
                    PermissionsView()
                    
                case .widgetSettings:
                    WidgetSettingsView()
                    
                #if DEBUG
                case .developer:
                    DeveloperView()
                #endif
                    
                case .knowledgeBase:
                    KnowledgeBaseView()
                    
                case .widgets:
                    WidgetPreviewView()
                    
                @unknown default:
                    EmptyView()
            }
        }
        .environment(self)
    }
}
