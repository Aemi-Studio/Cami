//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct SettingsView: View {

    @State private var authorizationStatus: EKAuthorizationSet = []
    @State private var contactAuthorizationStatus: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("Calendar Access")
                Spacer()
                Image(systemName: authorizationStatus.contains(.events) ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(authorizationStatus.contains(.events)
                                     ? .green : .red)
            }
            HStack {
                Text("Reminder Access")
                Spacer()
                Image(systemName: authorizationStatus.contains(.reminders) ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(authorizationStatus.contains(.reminders)
                                     ? .green : .red)
            }
            HStack {
                Text("Contact Access")
                Spacer()
                Image(systemName: authorizationStatus.contains(.reminders) ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(contactAuthorizationStatus ? .green : .red)
            }
        }
        .onAppear {
            Task {
                authorizationStatus = await CalendarHandler.request()
            }
            Task {
                contactAuthorizationStatus = await ContactHelper.request()
            }
        }
    }
}

#Preview {
    SettingsView()
}
