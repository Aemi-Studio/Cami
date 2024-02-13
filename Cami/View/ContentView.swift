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

    @Environment(\.scenePhase)
    var scenePhase: ScenePhase

    @EnvironmentObject
    private var perms: PermissionModel

    @EnvironmentObject
    private var model: ViewModel

    @State
    private var areSettingsPresented: Bool = false

    @State
    private var areInformationsPresented: Bool = false

    private var wasNotAuthorized: Bool = PermissionModel.shared.global.status == .restricted

    private var authorized: Bool {
        PermissionModel.shared.global == .authorized
    }

    private var restricted: Bool {
        PermissionModel.shared.global == .restricted
    }

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures: Bool = false

    var body: some View {
        Group {
            if accessWorkInProgressFeatures {
                NavigationStack(path: $model.path) {
                    CalendarView(
                        areSettingsPresented: $areSettingsPresented
                    )
                    .navigationDestination(for: Day.self, destination: DayView.init)
                    .navigationDestination(for: EKEvent.self, destination: EventView.init)
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
        .onChange(of: perms.global) { _, _ in
            model.reset()
            WidgetCenter.shared.reloadAllTimelines()
        }
        .sheet(isPresented: $areSettingsPresented) {
            PermissionsView()
                .environmentObject(model)
                .environmentObject(perms)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $areInformationsPresented) {
            InformationModalView()
                .environmentObject(model)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }
}
