//
//  DayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import SwiftUI
import EventKit

struct DayView: View {

    @Environment(\.views) private var views

    private let defaultSpace: Double = 24

    @State
    private var events: Events?

    @State
    private var savedZoom: Double = 0.0

    @GestureState
    private var zoom: Double = 0.0

    private func adaptive(size: Double = 1, factor: Double) -> Double {
        let computedSize = defaultSpace * size * factor
        if computedSize < defaultSpace {
            return defaultSpace
        } else
        if computedSize > defaultSpace * factor * 48 {
            return defaultSpace * factor * 48
        } else {
            return defaultSpace * size * factor
        }
    }

    func responsiveStartPoint(factor: Double) -> Double {
        defaultSpace * factor
    }

    func getDateIntervalSize(from startDate: Date, to endDate: Date) -> Double {
        let components = Calendar.autoupdatingCurrent.dateComponents(
            [.hour, .minute],
            from: startDate,
            to: endDate
        )
        let hours: Double = Double(components.hour!)
        let minutes: Double = Double(components.minute!)
        let size: Double = ((hours * 60 + minutes) / (24 * 60)) * (24 * 2)
        return size
    }

    func getEventSize(of event: EKEvent) -> Double {
        return getDateIntervalSize(from: event.startDate, to: event.endDate)
    }

    var day: Day

    init(_ day: Day) {
        self.day = day
    }

    private var magnifyGesture: _EndedGesture<GestureStateGesture<MagnifyGesture, Double>> {
        MagnifyGesture()
            .updating($zoom) { value, gestureState, _ in
                gestureState = value.magnification
            }
            .onEnded { value in
                self.savedZoom = value.magnification
            }
    }

    var body: some View {
        ScrollView {
            HStack {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(0..<48) { _ in
                            VStack {
                                Divider()
                                    .padding(0)
                                    .padding(.bottom, adaptive(factor: savedZoom * zoom))
                            }
                            .frame(minHeight: adaptive(factor: savedZoom * zoom))
                            .frame(maxHeight: adaptive(factor: savedZoom * zoom))
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .gesture(magnifyGesture)

                    VStack(alignment: .center, spacing: 0) {
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            if events != nil && events!.count > 0 {
                                ForEach(events!.filter {
                                    views?.calendars.contains($0.calendar.calendarIdentifier) == .some(true)
                                }, id: \.self) { event in
                                    Button {
                                        views?.path.append(event)
                                    } label: {
                                        HStack(alignment: .center, spacing: 0) {
                                            VStack {
                                                Text(event.title)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                if event.notes != nil && !event.notes!.isEmpty {
                                                    ViewThatFits {
                                                        Text(event.notes!)
                                                            .font(.body)
                                                            .fontWeight(.medium)
                                                            .lineLimit(1)
                                                    }
                                                }
                                            }
                                            .multilineTextAlignment(.leading)
                                            Spacer()
                                            VStack(alignment: .center, spacing: 2) {
                                                Text(
                                                    event.endDate.timeIntervalSince(event.startDate).formatted()
                                                )
                                            }
                                        }
                                        .frame(
                                            height: adaptive(
                                                size: getEventSize(of: event),
                                                factor: (1 + zoom * savedZoom)
                                            )
                                        )
                                        .roundedBorder(event.calendar.cgColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .gesture(magnifyGesture)
                                    .offset(CGSize(
                                        width: 0,
                                        height: responsiveStartPoint(
                                            factor: event.startDate.getStartPosition() * (1 + zoom * savedZoom)
                                        )
                                    ))
                                }
                            } else {
                                Text("No Events for Today.")
                            }
                        }
                    }
                    .gesture(magnifyGesture)
                }

                VStack(spacing: 0) {
                    ForEach(0..<48) { incr in
                        VStack {
                            let date = Calendar.autoupdatingCurrent.date(
                                from: DateComponents(minute: incr * 30)
                            )!
                            Text(date.formatter { formatter in
                                formatter.dateStyle = .none
                                formatter.timeStyle = .short
                            })
                            .monospacedDigit()
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .offset(.init(
                                        width: 0,
                                        height: adaptive(factor: savedZoom * zoom) / 2 * -1)
                            )
                        }
                        .frame(minHeight: adaptive(factor: savedZoom * zoom))
                        .frame(maxHeight: adaptive(factor: savedZoom * zoom))
                        .gesture(magnifyGesture)
                    }
                }
                .gesture(magnifyGesture)

            }
            .padding(0)
            .gesture(magnifyGesture)
            .navigationTitle(
                day.date.formatted(
                    .dateTime.day(.defaultDigits).day().month(.abbreviated).year()
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.async {
                    Task {
                        events = await day.lazyInitEvents()
                    }
                }
            }
            .padding()
        }
        .gesture(magnifyGesture)
    }
}

extension Date {

    func getStartPosition() -> Double {
        let components = self.get(.hour, .minute)
        let hours = components.hour!
        let minutes = components.minute!
        return Double(Double(hours) * 2 + Double(minutes / 30))
    }

}
