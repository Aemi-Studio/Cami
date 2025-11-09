//
//  OnboardingViewState.swift
//  Cami
//
//  Created by Guillaume Coquard on 10.11.25.
//

import SwiftUI

@Observable
@MainActor
final class OnboardingViewState: Loggable {
    private var state: AppState?
    private var permissions: PermissionManager?
    
    var currentStep: OnboardingStep?
    var actualSteps: [OnboardingStep] = []

    // MARK: - Actions
    
    private func initializeSteps(steps: [OnboardingStep]) {
        self.actualSteps = steps.filter { step in
            switch step {
                case .permissionCalendar: permissions?.calendarStatus != .authorized
                case .permissionReminders: permissions?.remindersStatus != .authorized
                case .permissionContacts: permissions?.contactsStatus != .authorized
                default: true
            }
        }
        self.currentStep = actualSteps.first
    }
    
    func load(
        app state: AppState,
        permissions: PermissionManager
    ) {
        self.state = state
        self.permissions = permissions
        
        initializeSteps(steps: state.onboardingSteps)
    }
    
    func next() {
        if let currentStep,
           let currentIndex = actualSteps.firstIndex(of: currentStep),
           let lastIndex = actualSteps.indices.last
        {
            if currentIndex < lastIndex {
                withAnimation { [weak self] in
                    guard let self else { return }
                    self.currentStep = actualSteps[currentIndex + 1]
                }
            } else {
                state?.completeOnboarding(steps: actualSteps)
            }
        }
    }
}
