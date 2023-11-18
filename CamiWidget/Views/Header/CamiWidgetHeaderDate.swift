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
    var widgetFamily: WidgetFamily

    @EnvironmentObject
    private var entry: CamiWidgetEntry

    private var datePrefix: Int {
        return switch widgetFamily {
            case .systemExtraLarge:
                Int.max
            case .systemSmall:
                1
            default:
                3
        }
    }

    var body: some View {
        HStack {
            let dateComponents = entry.date.literals

            Group {
                Text(
                    "\(dateComponents.name)"
                        .uppercased()
                        .prefix(datePrefix)
                )
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                +
                Text("\(dateComponents.number)")
                    .fontWeight(.heavy)
                    .foregroundStyle(.red)
            }
        }
        .font(.title3)
        .lineSpacing(0)
    }
}
