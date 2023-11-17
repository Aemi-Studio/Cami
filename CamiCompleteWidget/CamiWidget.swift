//
//  CamiWidget.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import WidgetKit
import SwiftUI

struct CamiWidget: Widget {
    let kind: String = "CamiWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CamiCompleteWidgetIntent.self,
            provider: CamiWidgetProvider()
        ) { entry in
            CamiWidgetEntryView(entry: entry)
                .containerBackground(Color(white:0.1), for: .widget)
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
