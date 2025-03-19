//
//  CamiWidget.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI
import WidgetKit

struct CamiWidget: Widget {
    let kind: String = "CamiWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CamiWidgetIntent.self, provider: CamiWidgetProvider()) { entry in
            CamiWidgetView(for: entry)
        }
        .containerBackgroundRemovable()
        .contentMarginsDisabled()
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ])
    }
}
