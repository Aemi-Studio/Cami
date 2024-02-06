//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI
import EventKit

struct ContentView: View {

    @Bindable
    var model: ViewModel

    #if !DEBUG
    @State
    private var isModalPresented: Bool = false

    @State
    private var wasNotAuthorized: Bool = true

    @State
    private var authorized: Bool = false
    #endif

    var body: some View {
        #if DEBUG
        NavigationStack(path: $model.path) {
            CalendarView()
                .navigationDestination(for: Day.self, destination: DayView.init)
                .navigationDestination(for: EKEvent.self, destination: EventView.init)
        }
        #else
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
                        Button {
                            isModalPresented.toggle()
                        } label: {
                            var desc = "Cami needs you to grant it access to your calendar and contacts information to work properly."
                            ButtonInnerBody(label: "Grant Access", description: desc, systemImage: "checkmark.circle.badge.questionmark", radius: 12)
                                .tint(.orange)
                        }
                        .sheet(isPresented: $isModalPresented) {
                            SettingsView()
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.fraction(0.75)])
                                .presentationContentInteraction(.scrolls)
                                .onDisappear {
                                    authorized = model.authStatus.calendars.status == .authorized
                                    if wasNotAuthorized && authorized {
                                        model.reset()
                                    }
                                }
                        }
                    } else {
                        Text("Stay tuned for next Cami updates.")
                        Spacer(minLength: 32)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                SettingsLinkView()
                WidgetHelpView(
                    title: "Privacy Policy",
                    url: "https://aemi.studio/privacy",
                    description: "Review how Cami handles your data."
                )
                WidgetHelpView(
                    title: "How to add and edit widgets on iPhone",
                    url: "https://support.apple.com/en-us/HT207122",
                    description: "Visit Apple Support."
                )
            }
            .lineLimit(10)
            .padding()
        }
        .onAppear {
            wasNotAuthorized = model.authStatus.calendars.status != .authorized
            authorized = model.authStatus.calendars.status == .authorized
        }
        #endif
    }
}
