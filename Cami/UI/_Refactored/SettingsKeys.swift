//
//  SettingsKeys.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

enum SettingsKeys: String, Hashable, CaseIterable, Equatable, Sendable, CustomStringConvertible {
    case hasCompletedInitialOnboarding
    case completedOnboardingSteps
    case accessWorkInProgressFeatures
    case openInCami
}

extension SettingsKeys {
    var description: String {
        switch self {
            case .hasCompletedInitialOnboarding:
                String(localized: "settingsKey.hasDismissedOnboarding")
            case .completedOnboardingSteps:
                String(localized: "settingsKey.completedOnboardingSteps")
            case .accessWorkInProgressFeatures:
                String(localized: "settingsKey.accessWorkInProgressFeatures")
            case .openInCami:
                String(localized: "settingsKey.openInCami")
        }
    }
}
