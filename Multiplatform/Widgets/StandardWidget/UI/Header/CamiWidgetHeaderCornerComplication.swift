//
//  CamiWidgetHeaderCornerComplication.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import SwiftUI
import WidgetKit

struct CamiWidgetHeaderCornerComplication: View {

    @Environment(\.widgetContent)
    private var content

    var body: some View {
        switch content.configuration.complication {
            case .hidden: EmptyView()
            case .birthdays: CamiWidgetHeaderBirthdays()
            case .summary: CamiWidgetHeaderEventSummary()
        }
    }
}
