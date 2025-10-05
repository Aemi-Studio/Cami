//
//  OnboardingFlowViews.swift
//  Cami
//
//  Created by Assistant on 05/10/25.
//

import SwiftUI
import WidgetKit

// MARK: - Intro
struct OnboardingIntroView: View {
    @Environment(AppNavigation.self) private var navigation
    @Environment(PermissionManager.self) private var permissionManager
    @AppStorage(SettingsKeys.hasDismissedOnboarding) private var hasDismissedOnboarding: Bool = false

    private var nextDestination: NavigationDestination { .onboardingPermissionsCalendar }

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeroView()
            Text(String(localized: "onboarding.description"))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            OnboardingCard(backgroundTint: .accentColor) {
                OnboardingPermissionActionButton {
                    navigation.navigate(to: nextDestination)
                }
            }

            skipButton
        }
        .padding()
        .navigationTitle(String(localized: "onboarding.navigation.title"))
        .toolbar { toolbarDismiss }
    }

    private var skipButton: some View {
        Button(String(localized: "onboarding.skip")) {
            hasDismissedOnboarding = true
            navigation.dismissSheet()
        }
        .buttonStyle(.borderless)
        .tint(.secondary)
    }

    @ToolbarContentBuilder private var toolbarDismiss: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "onboarding.close")) {
                hasDismissedOnboarding = true
                navigation.dismissSheet()
            }
        }
    }
}

// MARK: - Permission Step
struct OnboardingPermissionStepView: View {
    @Environment(AppNavigation.self) private var navigation
    @Environment(PermissionManager.self) private var permissionManager
    @AppStorage(SettingsKeys.hasDismissedOnboarding) private var hasDismissedOnboarding: Bool = false

    let permission: PermissionManager.Permission

    private var titleKey: LocalizedStringResource {
        switch permission {
        case .calendar: "perms.calendars.title"
        case .contacts: "perms.contacts.title"
        case .reminders: "perms.reminders.title"
        }
    }

    private var descriptionKey: LocalizedStringResource {
        switch permission {
        case .calendar: "perms.calendars.description"
        case .contacts: "perms.contacts.description"
        case .reminders: "perms.reminders.description"
        }
    }

    private var status: PermissionStatus {
        switch permission {
        case .calendar: permissionManager.calendarStatus
        case .contacts: permissionManager.contactsStatus
        case .reminders: permissionManager.remindersStatus
        }
    }

    private var nextDestination: NavigationDestination? {
        switch permission {
        case .calendar: .onboardingPermissionsContacts
        case .contacts: .onboardingPermissionsReminders
        case .reminders: .onboardingCompletion
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text(String(localized: titleKey))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(String(localized: descriptionKey))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            statusView

            actionSection
        }
        .padding()
        .navigationTitle(String(localized: "onboarding.permissions.step.title"))
        .toolbar { toolbarSkip }
        .task(id: status) {
            await continueIfAuthorized()
        }
    }

    @ViewBuilder private var statusView: some View {
        switch status {
        case .authorized:
            OnboardingDoneStatusView()
        case .denied, .restricted:
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.largeTitle)
                Text(String(localized: "onboarding.permissions.denied"))
                    .fontWeight(.semibold)
                Button(String(localized: "onboarding.permissions.openSettings"), systemImage: "gear") {
                    AppContext.open(.settings)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        case .notDetermined:
            ProgressView(String(localized: "onboarding.permissions.waiting"))
        }
    }

    @ViewBuilder private var actionSection: some View {
        switch status {
        case .authorized:
            if let next = nextDestination {
                Button(String(localized: "onboarding.next"), systemImage: "chevron.right") {
                    navigation.navigate(to: next)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(String(localized: "onboarding.finish"), systemImage: "checkmark.circle") {
                    completeOnboarding()
                }
                .buttonStyle(.borderedProminent)
            }
        case .notDetermined:
            Button(String(localized: "onboarding.permissions.request"), systemImage: "hand.tap") {
                Task { await requestPermission() }
            }
            .buttonStyle(.borderedProminent)
        case .denied, .restricted:
            EmptyView()
        }
    }

    private func requestPermission() async {
        _ = await permissionManager.request(permission)
    }

    private func continueIfAuthorized() async {
        if status == .authorized, let next = nextDestination {
            // Small delay to allow user to see granted state
            try? await Task.sleep(nanoseconds: 500_000_000)
            navigation.navigate(to: next)
        }
    }

    private func completeOnboarding() {
        hasDismissedOnboarding = true
        navigation.dismissSheet()
    }

    @ToolbarContentBuilder private var toolbarSkip: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "onboarding.skip")) { completeOnboarding() }
        }
    }
}

// MARK: - Completion
struct OnboardingCompletionView: View {
    @Environment(AppNavigation.self) private var navigation
    @AppStorage(SettingsKeys.hasDismissedOnboarding) private var hasDismissedOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.seal.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 64))
            Text(String(localized: "onboarding.completed.title"))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(String(localized: "onboarding.completed.subtitle"))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(String(localized: "onboarding.getStarted"), systemImage: "paperplane.fill") {
                completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle(String(localized: "onboarding.completed.nav"))
        .toolbar { ToolbarItem(placement: .cancellationAction) { dismissButton } }
    }

    private func completeOnboarding() {
        hasDismissedOnboarding = true
        navigation.dismissSheet()
    }

    private var dismissButton: some View {
        Button(String(localized: "onboarding.close")) { completeOnboarding() }
    }
}

#Preview("Onboarding Flow") {
    NavigationStack {
        OnboardingIntroView()
            .environment(AppNavigation())
            .environment(PermissionManager())
    }
}
