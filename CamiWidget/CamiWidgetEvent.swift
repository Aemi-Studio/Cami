//
//  CamiWidgetEvent.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetEvent: View {
    
    var event: EKEvent
    var isLast: Bool

    var body: some View {
        HStack(alignment:.center) {
            Group {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(Color(cgColor: event.calendar.cgColor))
                }
                Spacer(minLength: 8)
                if !event.isAllDay {
                    VStack(alignment: .trailing) {
                        RemainingTimeComponent(startDate: event.startDate, endDate: event.endDate)
                            .font(.system(.caption))
                            .foregroundStyle(Color(cgColor: event.calendar.cgColor))
                    }
                }

            }
        }
        .roundedBorder(
            event.calendar.cgColor,
            last: isLast
        )
    }
}

//#Preview {
//    CamiWidgetEvent()
//}
