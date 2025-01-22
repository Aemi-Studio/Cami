//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct ContentView: View {

    @Environment(\.scenePhase)  private var scenePhase: ScenePhase
    @Environment(\.permissions) private var permissions
    @Environment(\.views)       private var views

    @State private var areSettingsPresented: Bool = false
    @State private var areInformationsPresented: Bool = false

    private var wasNotAuthorized: Bool = PermissionModel.shared.global.status == .restricted

    private var authorized: Bool {
        permissions?.global == .some(.authorized)
    }

    private var restricted: Bool {
        permissions?.global == .some(.restricted)
    }

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures: Bool = false

    var body: some View {
        Group {
            if accessWorkInProgressFeatures {
                if let views {
                    @Bindable var views = views
                    NavigationStack(path: $views.path) {
                        CalendarView(
                            areSettingsPresented: $areSettingsPresented
                        )
                        .navigationDestination(for: Day.self, destination: DayView.init)
                        .navigationDestination(for: EKEvent.self, destination: EventView.init)
                    }
                }
            } else {
                OnboardingView(
                    areSettingsPresented: $areSettingsPresented,
                    areInformationsPresented: $areInformationsPresented
                )
                .frame(maxWidth: 720)
            }
        }
        .onChange(of: scenePhase) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: permissions?.global) { _, _ in
            views?.reset()
            WidgetCenter.shared.reloadAllTimelines()
        }
        .sheet(isPresented: $areSettingsPresented) {
            PermissionsView()
                .environment(\.views, views)
                .environment(\.permissions, permissions)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $areInformationsPresented) {
            InformationModalView()
                .environment(\.views, views)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }
}

#Preview {
    ContentView()
}


extension View {
    
    @ViewBuilder
    func awareSheet(
        isPresented condition: Binding<Bool>,
        environmentValues: [PartialKeyPath<EnvironmentValues>: Any],
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        self
            .sheet(isPresented: condition) {
                content()
            
            }
    }
    
}
