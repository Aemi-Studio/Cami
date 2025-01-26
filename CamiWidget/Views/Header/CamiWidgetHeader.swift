//
//  CamiWidgetHeader.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetHeader: View {

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    @AppStorage(SettingsKeys.openInCami)
    private var openInPlace: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.openInCami)

    var body: some View {

        @Bindable var entry = entry

        HStack(spacing: 0) {

            Link(destination: DataContext.shared.destination(for: entry.date, inPlace: openInPlace)) {
                CamiWidgetHeaderDate()
                    .accessibilityLabel("Today's date is " + entry.date.formatter {
                        $0.dateStyle = .full
                        $0.timeStyle = .none
                        $0.formattingContext = .standalone
                    })
            }

            Spacer()

            CamiWidgetHeaderCornerComplication()
        }
        .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 5))
        .background(.black.opacity(0.2))
        .rounded([ .all: .init( top: 16, bottom: 8 ) ])
        .lineLimit(1)
        .fontDesign(.rounded)
    }
}

// #Preview {
//    CamiWidgetHeader()
// }
