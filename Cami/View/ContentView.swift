//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//
// swiftlint:disable line_length

import SwiftUI
import EventKit
import WidgetKit

struct ContentView: View {

    @Environment(\.scenePhase)
    var scenePhase: ScenePhase

    @Bindable
    var model: ViewModel

    @Bindable
    var perms: PermissionModel

    @State
    private var isModalPresented: Bool = false

    @State
    private var isInformationModalPresented: Bool = false

    @State
    private var wasNotAuthorized: Bool = true

    @State
    private var authorized: Bool = PermissionModel.shared.global.status == .authorized

    @State
    private var restricted: Bool = PermissionModel.shared.global.status != .authorized

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures: Bool = false

    var body: some View {
        Group {
            if accessWorkInProgressFeatures {
                NavigationStack(path: $model.path) {
                    CalendarView()
                        .navigationDestination(for: Day.self, destination: DayView.init)
                        .navigationDestination(for: EKEvent.self, destination: EventView.init)
                }
            } else {
                OnboardingView(
                    authorized: $authorized,
                    restricted: $restricted,
                    isModalPresented: $isModalPresented,
                    isInformationModalPresented: $isInformationModalPresented
                )
            }
        }
        .onAppear {
            wasNotAuthorized = perms.global.status != .authorized
            authorized = perms.global.calendars.status == .authorized
                && perms.global.contacts.status == .authorized
            restricted = perms.global.calendars.status == .restricted
                && perms.global.contacts.status == .restricted
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                WidgetCenter.shared.reloadAllTimelines()
            case .inactive, .background:
                WidgetCenter.shared.reloadAllTimelines()
            @unknown default:
                WidgetCenter.shared.reloadAllTimelines()

            }
        }
        .sheet(isPresented: $isModalPresented) {
            SettingsView()
                .environmentObject(model)
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
                .presentationContentInteraction(.scrolls)
                .onDisappear {
                    authorized = perms.global.calendars.status == .authorized
                        && perms.global.contacts.status == .authorized
                    restricted = perms.global.calendars.status == .restricted
                        && perms.global.contacts.status == .restricted
                    if wasNotAuthorized && authorized {
                        model.reset()
                    }
                }
        }
        .sheet(isPresented: $isInformationModalPresented) {
            InformationModalView()
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }
}
