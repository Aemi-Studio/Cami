//
//  SummaryCountView.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct SummaryCountView: View {
    @Environment(AppNavigation.self) private var navigation: AppNavigation?

    private(set) var kind: CalendarItemKind
    private(set) var count: Int
    @Binding private(set) var binding: Bool

    var body: some View {
        toggle
            .contextMenu { contextMenu }
    }

    private var toggle: some View {
        Toggle(isOn: $binding) {
            Text(count == 1 ? kind.description : kind.pluralDescription)
        }
        .toggleStyle(.unifiedCapsule(count: count))
    }

    private var contextMenu: some View {
        Button(kind.listPluralDescription, systemImage: kind.listSystemImage) {
            navigation?.navigate(to: .calendarSelection(kind: kind))
        }
    }
}
