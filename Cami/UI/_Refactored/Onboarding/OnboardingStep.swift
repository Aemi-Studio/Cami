//
//  OnboardingStep.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

enum OnboardingStep: Int, CaseIterable, Hashable, Sendable, Equatable {
    case welcome = 0
    case permissionCalendar
    case permissionReminders
    case permissionContacts
    case ready
}

extension OnboardingStep {
    static var initialOnboarding: [OnboardingStep] {
        [
            .welcome,
            .permissionCalendar,
            .permissionReminders,
            .permissionContacts,
            .ready
        ]
    }
}
