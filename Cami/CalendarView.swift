//
//  CalendarView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI
import EventKit
import Contacts

struct CalendarView: View {
    
    private var birthdays: [EKEvent] {
        return CalendarHandler.events().1
    }

    var nextBirthdays: (Int, [String]) {

        let firstBirthday : EKEvent = birthdays[0]

        var peopleBirthdays: [String] = birthdays.filter { event in
            event.isSameDayAs(event: firstBirthday)
        }.map { event in
            ContactHelper.getNameFromContactIdentifier(event.birthdayContactIdentifier!)
        }

        peopleBirthdays.insert(
            ContactHelper.getNameFromContactIdentifier(
                firstBirthday.birthdayContactIdentifier!
            ),
            at: 0
        )

        let result = (
            Int((firstBirthday.endDate.zero - Date.now.zero) / (24 * 3600)),
            peopleBirthdays
        )

        print(result.0.description)
        print(result.1.description)

        return result
    }

    var body: some View {
        ScrollView {
            ForEach(birthdays, id: \.self) { birthday in
                VStack {
                    HStack {
                        Text(ContactHelper.getNameFromContactIdentifier(birthday.birthdayContactIdentifier!))
                        Spacer()
                        Text(birthday.endDate.description)
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
