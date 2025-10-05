//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

struct OnboardingView: View {
    @Environment(AppState.self) private var state
    @Environment(AppNavigation.self) private var navigation
    @Environment(PermissionManager.self) private var permissionManager

    @State private var steps: [OnboardingStep] = []
    @State private var currentStep: OnboardingStep?

    private var actualSteps: [OnboardingStep] {
        steps.filter { step in
            switch step {
                case .permissionCalendar: permissionManager.calendarStatus != .authorized
                case .permissionReminders: permissionManager.remindersStatus != .authorized
                case .permissionContacts: permissionManager.contactsStatus != .authorized
                default: true
            }
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(actualSteps, id: \.self) { step in
                    view(for: step)
                        .padding()
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentStep, anchor: .leading)
        .toolbar { bottom }
        .task {
            steps = state.onboardingSteps
            currentStep = actualSteps.first
        }
        .presentationDetents([.medium, .large], selection: $presentationDetent)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }
    
    @State private var presentationDetent: PresentationDetent = .medium
    
    @ViewBuilder
    private func view(for step: OnboardingStep?) -> some View {
        switch step {
            case .permissionCalendar:
                OnboardingCalendarPermissionView(goToNextStep: next)
            case .permissionReminders:
                OnboardingRemindersPermissionView(goToNextStep: next)
            case .permissionContacts:
                OnboardingContactsPermissionView(goToNextStep: next)
            case .ready:
                OnboardingReadyView()
            case .welcome:
                OnboardingWelcomeView()
            case .none:
                EmptyView()
        }
    }
    
    @ToolbarContentBuilder
    private var bottom: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(
                "Next",
                systemImage: "arrow.forward",
                action: next
            )
        }
    }
    
    private func next() {
        if let currentStep,
           let currentIndex = actualSteps.firstIndex(of: currentStep),
           let lastIndex = actualSteps.indices.last
        {
            if currentIndex < lastIndex {
                withAnimation {
                    self.currentStep = actualSteps[currentIndex + 1]
                }
            } else {
                state.completeOnboarding(steps: steps)
            }
        }
    }
}

private struct OnboardingWelcomeView: View {
    var body: some View {
        OnboardingHeroView()
    }
}

private struct OnboardingReadyView: View {
    var body: some View {
        Text("Ready")
    }
}

private struct OnboardingCalendarPermissionView: View {
    @Environment(PermissionManager.self) private var permissionManager
    
    let goToNextStep: () -> Void
    
    var body: some View {
        OnboardingPermissionView(
            type: CalendarPermission(),
            status: permissionManager.calendarStatus,
            requestAction: {
                if await permissionManager.request(.calendar) == .authorized {
                    try? await Task.sleep(for: .milliseconds(500))
                    await MainActor.run {
                        goToNextStep()
                    }
                }
            }
        )
    }
}

private struct OnboardingRemindersPermissionView: View {
    @Environment(PermissionManager.self) private var permissionManager
    
    let goToNextStep: () -> Void
    
    var body: some View {
        OnboardingPermissionView(
            type: RemindersPermission(),
            status: permissionManager.remindersStatus,
            requestAction: {
                if await permissionManager.request(.reminders) == .authorized {
                    try? await Task.sleep(for: .milliseconds(500))
                    await MainActor.run {
                        goToNextStep()
                    }
                }
            }
        )
    }
}

private struct OnboardingContactsPermissionView: View {
    @Environment(PermissionManager.self) private var permissionManager
    
    let goToNextStep: () -> Void
    
    var body: some View {
        OnboardingPermissionView(
            type: ContactsPermission(),
            status: permissionManager.contactsStatus,
            requestAction: {
                if await permissionManager.request(.contacts) == .authorized {
                    try? await Task.sleep(for: .milliseconds(500))
                    await MainActor.run {
                        goToNextStep()
                    }
                }
            }
        )
    }
}

private struct OnboardingPermissionView<Permission>: View where Permission: PermissionType {
    @Environment(PermissionManager.self) private var permissionManager
    
    let type: Permission
    let status: PermissionStatus
    let requestAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(type.title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
            
            Text(type.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await requestAction()
                    await MainActor.run {
                        permissionManager.refresh()
                    }
                }
            } label: {
                Text("Grant Access")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
    }
}
