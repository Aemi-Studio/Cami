//
//  EventDetailView.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/11/25.
//

import EventKit
import EventKitUI
import SwiftUI

/// Wrapper view that fetches an event by identifier and displays it
struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.data) private var dataContext

    let identifier: String

    @State private var event: EKEvent?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let event {
                EventViewController(event: event)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "Event Not Found",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("The event could not be found or has been deleted.")
                )
            }
        }
        .task {
            await loadEvent()
        }
    }

    private func loadEvent() async {
        isLoading = true
        event = await MainActor.run {
            dataContext?.event(for: identifier)
        }
        isLoading = false
    }
}
