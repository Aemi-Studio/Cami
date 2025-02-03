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
        AppIntentConfiguration(
            kind: kind,
            intent: CamiWidgetIntent.self,
            provider: CamiWidgetProvider()
        ) { entry in
            CamiWidgetView(for: entry)
                .containerBackground(Color(white: 0.1), for: .widget)
                .environment(\.data, .shared)
                .environment(\.locale, .prefered)
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
