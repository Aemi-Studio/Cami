//
//  CalendarSelectionView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import SwiftUI

struct CalendarSelectionView: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    private func isSelected(_ calendar: String) -> Bool {
        model.calendars.contains(calendar)
    }

    var allCalendars: Calendars {
        CamiHelper.allCalendars
    }

    var calendarsAsDict: [String: Calendars] {
        CamiHelper.allCalendars.reduce(into: [String: Calendars]()) { r, c in
            let sourceTitle: String = c.source.title
            if let oldValue = r[sourceTitle] {
                var newValue = oldValue
                newValue.append(c)
                r.updateValue(newValue, forKey: sourceTitle)
            } else {
                r[sourceTitle] = [c]
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calendarsAsDict.keys.sorted(), id: \.self) { source in
                    Section {
                        ForEach(calendarsAsDict[source]!, id: \.self) { calendar in
                            Button {
                                if !isSelected(calendar.calendarIdentifier) {
                                    model.calendars.insert(calendar.calendarIdentifier)
                                } else {
                                    model.calendars.remove(calendar.calendarIdentifier)
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 8) {
                                    VStack(alignment: .leading) {
                                        let imageName = isSelected(calendar.calendarIdentifier)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                        Label("\(calendar.source.title) - \(calendar.title)", systemImage: imageName)
                                            .labelStyle(.iconOnly)
                                            .foregroundStyle(Color(cgColor: calendar.cgColor))
                                    }
                                    .fontWeight(.bold)
                                    .font(.title)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(calendar.title)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.foreground)
                                    }
                                }
                                .padding()
                            }
                            .buttonStyle(.bordered)
                        }
                    } header: {
                        Text(source)
                            .font(.subheadline)
                            .foregroundStyle(.foreground.secondary)
                    }
                }
            }
        }
        .safeAreaPadding(.top)
        .padding()
    }
}

#Preview {
    CalendarSelectionView()
}
