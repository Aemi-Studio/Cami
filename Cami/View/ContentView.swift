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

    @Environment(\.scenePhase)   private var scenePhase
    @Environment(\.presentation) private var presentation
    @Environment(\.permissions)  private var permissions
    @Environment(\.views)        private var views

    @State private var pages: [Page] = [.onboarding, .day(Date.now), .permissions]

    private var wasNotAuthorized: Bool = PermissionModel.shared.global == .restricted

    private var authorized: Bool {
        permissions?.global == .some(.authorized)
    }

    private var restricted: Bool {
        permissions?.global == .some(.restricted)
    }

    var body: some View {
        ScrollableHome(pages)
            .onChange(of: scenePhase) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: permissions?.global) { _, _ in
                views?.reset()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(DataContext.shared.publishEventStoreChanges()) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .if(presentation != nil) { view in
                @Bindable var presentation = presentation!
                view
                    .modal(isPresented: $presentation.areSettingsPresented) {
                        PermissionsView()
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.medium, .large])
                            .presentationContentInteraction(.scrolls)
                    }
                    .modal(isPresented: $presentation.areInformationsPresented) {
                        InformationModalView()
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                            .presentationContentInteraction(.scrolls)
                    }
                    .modal(isPresented: $presentation.isReminderCreationSheetPresented) {
                        CreateReminderView()
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                            .presentationContentInteraction(.scrolls)
                    }
            }
    }

    @ViewBuilder
    var otherContent: some View {
        if let views {
            @Bindable var views = views
            NavigationStack(path: $views.path) {
                CalendarView()
                    //                    .navigationDestination(for: Day.self, destination: DayView.init)
                    .navigationDestination(for: EKEvent.self, destination: EventView.init)
            }
        }
    }
}

#Preview {
    ContentView()
}

struct CreateReminderView: View {

    @Environment(\.data) private var data
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now

    var readyToSave: Bool {
        !title.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 16)
                DatePicker("Date", selection: $date)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 16)
            }
            .padding()
            .navigationTitle("Create a Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Save") {
                        if readyToSave,
                           let data,
                           (try? data.createReminder(title: title)) != nil {
                            dismiss()
                        }
                    }
                    .disabled(!readyToSave)
                }
            }
        }
    }
}
