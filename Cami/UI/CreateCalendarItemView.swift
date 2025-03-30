//
//  CreateCalendarItemView.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import SwiftUI

struct CreateCalendarItemView: View {
    @Environment(\.data) private var data
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now

    private var readyToSave: Bool {
        !title.isEmpty
    }

    var body: some View {
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
