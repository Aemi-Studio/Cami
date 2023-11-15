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
    var birthdays: [EKEvent]

    var body: some View {
        HStack(spacing: 0) {
            CamiWidgetHeaderDate(date: date)
            Spacer()
            CamiWidgetBirthdays(date: date, birthdays: birthdays)
        }
        .padding([.vertical,.trailing], 4)
        .padding(.leading, 8)
        .background(.clear)
        .background(Color(white: 0).opacity(0.2))
        .clipShape(
            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 16,
                bottomLeading: 4,
                bottomTrailing: 4,
                topTrailing: 16
            ))
        )
        .lineLimit(1)
        .fontDesign(.rounded)
    }
}

//#Preview {
//    CamiWidgetHeader()
//}
