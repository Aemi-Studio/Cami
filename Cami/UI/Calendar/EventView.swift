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
    @State
    private var showEventEditView: Bool = false

    var event: EKEvent

    init(_ event: EKEvent) {
        self.event = event
    }

    var body: some View {
        ScrollView {
            EventViewController(event: event)
        }
        .navigationTitle("Details")
        .toolbar {
            if event.calendar.allowsContentModifications {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Edit") {
                        self.showEventEditView.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showEventEditView) {
            EditEventViewController(event: self.event)
                .onDisappear {
                    event.refresh()
                }
        }
        .onAppear {
            event.refresh()
        }
    }
}
