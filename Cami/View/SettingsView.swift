//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct SettingsView: View {

    @State private var authStatus: AuthSet = CamiHelper.authorizationStatus()

    private func statusToSymbolName(_ status: AuthSet.Status) -> String {
        switch status {
            case .authorized:
                "checkmark.circle.fill"
            case .restricted:
                "xmark.circle.fill"
            case .notDetermined:
                "circle"
        }
    }

    private func statusToStatusColor(_ status: AuthSet.Status) -> Color {
        switch status {
            case .authorized:
                .blue
            case .restricted:
                .red
            case .notDetermined:
                .gray
        }
    }

    var body: some View {
        VStack(spacing: 8) {

            Button {
                Task {
                    if authStatus.calendars.status == .notDetermined  {
                        authStatus.insert(await CalendarHelper.requestAccess())
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: statusToSymbolName(authStatus.calendars.status))
                        .foregroundStyle(statusToStatusColor(authStatus.calendars.status))
                        .padding()
                    VStack(alignment: .leading) {
                        Text("Calendars Access")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Description Placeholder")
                    }
                    Spacer()

                }
                .padding()
                .background(.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authStatus.calendars.status == .authorized)

            Button {
                Task {
                    if !Bool(authStatus.reminders.status) {
                        authStatus.insert(await ReminderHelper.requestAccess())
                    }
                }
            } label: {
                HStack(spacing: 4) {

                    Image(systemName: statusToSymbolName(authStatus.reminders.status))
                        .foregroundStyle(statusToStatusColor(authStatus.reminders.status))
                        .padding()
                    VStack(alignment: .leading) {
                        Text("Reminders Access")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Description Placeholder")
                    }
                    Spacer()
                }
                .padding()
                .background(.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authStatus.reminders.status == .authorized)

            Button {
                Task {
                    if authStatus.contacts.status == .notDetermined {
                        authStatus.insert(await ContactHelper.requestAccess())
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: statusToSymbolName(authStatus.contacts.status))
                        .foregroundStyle(statusToStatusColor(authStatus.contacts.status))
                        .padding()
                    VStack(alignment: .leading) {
                        Text("Contacts Access")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Description Placeholder")
                    }
                    Spacer()
                }
                .padding()
                .background(.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authStatus.contacts.status == .authorized)


        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
