//
//  NavigationExtensions.swift
//  Cami
//
//  Advanced navigation patterns and utilities
//

import SwiftUI

// MARK: - Navigation Coordinator Protocol

@MainActor
protocol NavigationCoordinating {
    func handleUserAction(_ action: UserAction)
    func handleDeepLink(_ url: URL)
    func performComplexFlow(_ flow: NavigationFlow)
}

enum UserAction {
    case openSettings
    case completeOnboarding
}

enum NavigationFlow {
    case onboarding
}

// MARK: - AppNavigation Coordinator Extension

extension AppNavigation: NavigationCoordinating {
    func handleUserAction(_ action: UserAction) {
        switch action {
        case .openSettings:
            navigate(to: .settings)
            
        case .completeOnboarding:
            dismissAllModals()
            navigate(to: .main)
        }
    }
    
    func handleDeepLink(_ url: URL) {
        guard let host = url.host else { return }
        
        // Reset to clean state for deep link
        reset()
        
        switch host {
        case "settings":
            navigate(to: .settings)
            
        default:
            break
        }
    }
    
    func performComplexFlow(_ flow: NavigationFlow) {
        switch flow {
        case .onboarding:
                // Present onboarding as sheet
                sheetDestination = .onboarding
        }
    }
}
