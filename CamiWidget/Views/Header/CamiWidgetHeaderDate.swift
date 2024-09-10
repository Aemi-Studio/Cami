//
//  CamiWidgetHeaderDate.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import SwiftUI
import WidgetKit

struct CamiWidgetHeaderDate: View {

    @Environment(\.widgetFamily)
    private var widgetFamily: WidgetFamily

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    private var dayLength: String {
        return switch widgetFamily {
        case .systemExtraLarge:
            "long"
        case .systemSmall:
            "short"
        default:
            "medium"
        }
    }

    var body: some View {

        @Bindable var entry = entry

        HStack(spacing: 0) {
            let dateComponents: [String: String] = entry.date.literals

            Text(
                "\(dateComponents[dayLength]!)"
                    .uppercased()
            )
            .fontWeight(.heavy)
            .foregroundStyle(.white)

            Text("\(dateComponents["date"]!)")
                .fontWeight(.heavy)
                .foregroundStyle(.red)

        }
        .font(.title3)
        .lineSpacing(0)
    }
}
