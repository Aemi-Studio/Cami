//
//  AddEventView.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/11/23.
//

import SwiftUI
import EventKit

struct EventView: View {

    @State private var editMode: EditMode = EditMode.inactive

    private var isEditing: Bool {
        editMode == .active
    }

    var event: EKEvent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text(event!.title)
//                    Text(event.isAllDay.description)
//                    Text(event.startDate)
//                    Text(event.endDate)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Details")
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                EditButton()
            }
        }
    }
}

#Preview {
 EventView()
}
