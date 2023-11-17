//
//  CamiWidgetHeaderDate.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI
import WidgetKit

struct CamiWidgetHeaderDate: View {

    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    var datePrefix: Int {
        switch widgetFamily {
            case .systemSmall:
                return 1
            default:
                return 3
        }
    }

    var date: Date

    var body: some View {
        HStack {
            let dateComponents = CamiUtils.getDayFromDate(date: date)
            Group {
                Text(
                    "\(dateComponents.0)"
                        .uppercased()
                        .prefix(datePrefix)
                )
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                +
                Text("\(dateComponents.1)")
                    .fontWeight(.heavy)
                    .foregroundStyle(.red)
            }
        }
        .font(.title3)
        .lineSpacing(0)
    }
}
