//
//  CamiWidgetEventsByDate.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetEventsByDate: View {
    
    var date: Date
    var events: [EKEvent]
    var isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(CamiUtils.relativeDate(date))
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .font(.system(size:12))
                    .foregroundStyle(.white.opacity(0.25))
                Spacer()
            }
            VStack(spacing: 2) {
                ForEach(0..<events.count, id: \.self) { index in
                    ViewThatFits {
                        CamiWidgetEvent(
                            event: events[index],
                            isLast: false // isLast && index == events.count - 1
                        )
                    }
                }
            }
        }
    }
}

//#Preview {
//    CamiWidgetEventsByDate()
//}
