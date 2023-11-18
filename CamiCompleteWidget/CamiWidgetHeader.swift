//
//  CamiWidgetHeader.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetHeader: View {

    var date: Date
    var config: CamiWidgetConfiguration

    var birthdays: EventList {
        if config.displayBirthdays {
            return CamiHelper.birthdays()
        } else {
            return []
        }
    }

    var body: some View {

        HStack(spacing: 0) {
            CamiWidgetHeaderDate(date: date)
            Spacer()
            if !birthdays.isEmpty {
                CamiWidgetBirthdays(
                    date: date,
                    birthdays: birthdays
                )
            }
        }
        .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 4))
        .background(.black.opacity(0.2))
        .rounded([ .all: .init( top: 16, bottom: 8 ) ])
        .lineLimit(1)
        .fontDesign(.rounded)
    }
}

//#Preview {
//    CamiWidgetHeader()
//}
