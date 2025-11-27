//
//  EventView.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/11/23.
//

import Contacts
import EventKit
import SwiftUI

struct EventView: View {
    @Environment(\.data) private var data

    @State private var showEventEditView: Bool = false
    @State private var eventStore: EKEventStore?

    let event: EKEvent

    init(_ event: EKEvent) {
        self.event = event
    }

    var body: some View {
        ScrollView {
            EventViewController(event: event)
        }
        .navigationTitle(String(localized: "view.details.navigationTitle"))
        .toolbar {
            if event.calendar.allowsContentModifications {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(String(localized: "button.edit")) {
                        showEventEditView.toggle()
                    }
                    .disabled(eventStore == nil)
                }
            }
        }
        .sheet(isPresented: $showEventEditView) {
            if let eventStore {
                EditEventViewController(event: event, eventStore: eventStore)
                    .onDisappear {
                        event.refresh()
                    }
            }
        }
        .task {
            eventStore = await data?.store
        }
        .onAppear {
            event.refresh()
        }
    }
}
