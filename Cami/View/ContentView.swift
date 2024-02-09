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

    @Bindable
    var model: ViewModel

    #if !DEBUG
    @State
    private var isModalPresented: Bool = false

    @State
    private var isInformationModalPresented: Bool = false

    @State
    private var wasNotAuthorized: Bool = true

    @State
    private var authorized: Bool = false

    @State
    private var restricted: Bool = false
    #endif

    var body: some View {
        #if DEBUG
        NavigationStack(path: $model.path) {
            CalendarView()
                .navigationDestination(for: Day.self, destination: DayView.init)
                .navigationDestination(for: EKEvent.self, destination: EventView.init)
        }
        #elseif !DEBUG
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {

                VStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 32)
                    VStack {
                        Text("Welcome to")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Cami Calendar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer(minLength: 32)
                    Text("""
    Cami Calendar, in its current version, is only a widget.
    We propose it as a better and improved way to display your current native calendar content on your homescreen.
    """)
                    Spacer(minLength: 32)
                    if !authorized {

                        if restricted {
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            } label: {
                                ButtonInnerBody(
                                    label: "Restricted",
                                    description: "Review Cami access to data.",
                                    systemImage: "gear",
                                    radius: 8,
                                    border: true
                                )
                                .tint(.red)
                            }
                        } else {
                            Button {
                                isModalPresented.toggle()
                            } label: {
                                var desc = "Cami needs you to grant it access to your calendar and contacts information to work properly."
                                ButtonInnerBody(label: "Grant Access", description: desc, systemImage: "checkmark.circle.badge.questionmark", radius: 8, border: true)
                                    .tint(.orange)
                            }
                        }

                    } else {
                        ButtonInnerBody(label: "Everything is fine.", description: "Stay tuned for next Cami updates.", radius: 8, alignment: .center, noIcon: true)
                            .tint(.green)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contextMenu {
                    Button("Refresh Widgets", systemImage: "arrow.clockwise") {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                WidgetHelpView(
                    title: "How to add and edit widgets on iPhone",
                    url: "https://support.apple.com/en-us/HT207122",
                    description: "Visit Apple Support."
                )

                Button {
                    isInformationModalPresented.toggle()
                }label: {
                    ButtonInnerBody(label: "Information", description: "Understand how Cami works.", systemImage: "info.circle")
                        .tint(.blue)
                }

                WidgetHelpView(
                    title: "Privacy Policy",
                    url: "https://aemi.studio/privacy",
                    description: "Review how Cami handles your data."
                )

                SettingsLinkView()
            }
            .lineLimit(10)
            .padding()
        }
        .onAppear {
            wasNotAuthorized = model.authStatus.status != .authorized
            authorized = model.authStatus.calendars.status == .authorized
                && model.authStatus.contacts.status == .authorized
            restricted = model.authStatus.calendars.status == .restricted
                && model.authStatus.contacts.status == .restricted

            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                WidgetCenter.shared.reloadAllTimelines()
            case .inactive, .background:
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .sheet(isPresented: $isModalPresented) {
            SettingsView()
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.75)])
                .presentationContentInteraction(.scrolls)
                .onDisappear {
                    authorized = model.authStatus.calendars.status == .authorized
                        && model.authStatus.contacts.status == .authorized
                    restricted = model.authStatus.calendars.status == .restricted
                        && model.authStatus.contacts.status == .restricted
                    if wasNotAuthorized && authorized {
                        model.reset()
                    }
                }
        }
        .sheet(isPresented: $isInformationModalPresented) {
            InformationModalView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        #endif
    }
}
