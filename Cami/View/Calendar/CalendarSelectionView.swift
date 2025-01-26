//
//  CalendarSelectionView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import SwiftUI

struct CalendarSelectionView: View {

    @Environment(\.views) private var views
    @Environment(\.data) private var data

    var calendars: Calendars {
        data?.calendars ?? []
    }

    var calendarsAsDict: [String: Calendars] {
        calendars.reduce(into: [String: Calendars]()) { result, calendar in
            let sourceTitle: String = calendar.source.title
            if let oldValue = result[sourceTitle] {
                var newValue = oldValue
                newValue.append(calendar)
                result.updateValue(newValue, forKey: sourceTitle)
            } else {
                result[sourceTitle] = [calendar]
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
                                    views?.calendars.insert(calendar.calendarIdentifier)
                                } else {
                                    views?.calendars.remove(calendar.calendarIdentifier)
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

    private func isSelected(_ calendar: String) -> Bool {
        views?.calendars.contains(calendar) ?? false
    }
}

#Preview {
    CalendarSelectionView()
}
