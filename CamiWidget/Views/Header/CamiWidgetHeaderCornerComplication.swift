//
//  CamiWidgetHeaderCornerComplication.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import SwiftUI
import WidgetKit

struct CamiWidgetHeaderCornerComplication: View {

    @Environment(\.widgetFamily)
    private var widgetFamily: WidgetFamily

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    var body: some View {
        switch entry.config.cornerComplication {
        case .hidden:
            EmptyView()
        case .birthdays:
            CamiWidgetHeaderBirthdays()
        case .summary:
            CamiWidgetHeaderEventSummary()
        }
    }
}
