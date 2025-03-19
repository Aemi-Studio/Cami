//
//  CreateCalendarItemButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import SwiftUI

struct CreateCalendarItemButton: View {
    @Environment(\.presentation)
    private var presentation

    func openReminderCreationSheet() {
        presentation.isCreationSheetPresented = true
    }

    var body: some View {
        Button {
            withAnimation {
                openReminderCreationSheet()
            }
        } label: {
            Image(systemName: "circle")
                .foregroundStyle(.clear)
                .overlay {
                    Label("Create a reminder", systemImage: "plus")
                        .foregroundStyle(Color.primary)
                        .labelStyle(.iconOnly)
                        .fontWeight(.medium)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 8))
                .thinBorder(radius: 8)
        }
    }
}
