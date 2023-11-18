//
//  CamiWidgetEntryView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import Foundation
import SwiftUI
import WidgetKit
import EventKit

struct CamiWidgetEntryView : View {
    var entry: CamiWidgetEntry

    private let now = Date.now

    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                CamiWidgetHeader(
                    date: now,
                    config: entry.config
                )
                Color.clear
                    .overlay(alignment:.top) {
                        CamiWidgetEvents(
                            events: entry.events,
                            config: entry.config
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(6)

            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color(white: 0.1).opacity(0),
                        Color(white: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(maxWidth: .infinity, maxHeight: 64)
            }
        }
    }
}
