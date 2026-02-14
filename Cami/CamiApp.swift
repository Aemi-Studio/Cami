import Contacts
import EventKit
import SwiftUI
import WidgetKit

@main
struct CamiApp: App {
    @State private var model = AppViewModel(repository: EventKitTimelineRepository())
    @AppStorage("cami.onboarding.completed")
    private var onboardingCompleted = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AppRootView(model: model)
            }
            .task {
                await model.refresh()
            }
            .onOpenURL { url in
                Task {
                    await model.handle(url: url)
                }
            }
            .sheet(isPresented: .constant(!onboardingCompleted)) {
                OnboardingFlowView(model: model) {
                    onboardingCompleted = true
                }
                .interactiveDismissDisabled()
                .presentationDetents([.large])
            }
        }
    }
}

@MainActor
@Observable
final class AppViewModel {
    private let repository: any TimelineRepository

    var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    var snapshot: DaySnapshot = .empty
    var showEvents = true
    var showReminders = true
    var isLoading = false
    var errorMessage: String?

    var hasCalendarAccess = false
    var hasRemindersAccess = false
    var hasContactsAccess = false

    init(repository: any TimelineRepository) {
        self.repository = repository
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        hasCalendarAccess = await repository.calendarAuthorizationStatus == .authorized
        hasRemindersAccess = await repository.remindersAuthorizationStatus == .authorized
        hasContactsAccess = await repository.contactsAuthorizationStatus == .authorized

        do {
            snapshot = try await repository.fetchDaySnapshot(
                for: selectedDate,
                showEvents: showEvents,
                showReminders: showReminders
            )
        } catch {
            errorMessage = String(localized: "Unable to load calendar data.")
            snapshot = .empty
        }

        isLoading = false
    }

    func moveDay(by days: Int) async {
        selectedDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
        await refresh()
    }

    func toggleEvents(_ value: Bool) async {
        showEvents = value
        await refresh()
    }

    func toggleReminders(_ value: Bool) async {
        showReminders = value
        await refresh()
    }

    func requestCalendarAccess() async {
        _ = await repository.requestCalendarAccess()
        await refresh()
    }

    func requestRemindersAccess() async {
        _ = await repository.requestRemindersAccess()
        await refresh()
    }

    func requestContactsAccess() async {
        _ = await repository.requestContactsAccess()
        await refresh()
    }

    func handle(url: URL) async {
        guard url.scheme?.lowercased() == "camical" || url.scheme?.lowercased() == "cami" else {
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = components?.host?.lowercased()
        let query: [String: String] = Dictionary(
            uniqueKeysWithValues: (components?.queryItems ?? []).compactMap { item in
                guard let value = item.value else {
                    return nil
                }
                return (item.name, value)
            }
        )

        if host == "day", let time = query["time"], let rawValue = Double(time) {
            selectedDate = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: rawValue))
            await refresh()
        }
    }
}

struct AppRootView: View {
    @Bindable var model: AppViewModel
    @AppStorage("cami.widget.openInApp")
    private var openInCami = true

    var body: some View {
        VStack(spacing: 12) {
            DayHeaderView(
                selectedDate: model.selectedDate,
                goPrevious: { Task { await model.moveDay(by: -1) } },
                goNext: { Task { await model.moveDay(by: 1) } }
            )

            HStack(spacing: 10) {
                Toggle(
                    String(localized: "Events"),
                    isOn: Binding(
                        get: { model.showEvents },
                        set: { newValue in
                            Task { await model.toggleEvents(newValue) }
                        }
                    )
                )
                .toggleStyle(.button)
                .accessibilityHint(String(localized: "Show or hide events in the day timeline."))

                Toggle(
                    String(localized: "Reminders"),
                    isOn: Binding(
                        get: { model.showReminders },
                        set: { newValue in
                            Task { await model.toggleReminders(newValue) }
                        }
                    )
                )
                .toggleStyle(.button)
                .accessibilityHint(String(localized: "Show or hide reminders in the day timeline."))
            }

            PermissionBannerView(model: model)

            if model.isLoading {
                ProgressView(String(localized: "Loading timeline"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = model.errorMessage {
                ContentUnavailableView(
                    String(localized: "Could not load"),
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if model.snapshot.items.isEmpty {
                ContentUnavailableView(
                    String(localized: "No items for this day"),
                    systemImage: "calendar.badge.clock",
                    description: Text(String(localized: "Try enabling events/reminders or pick another day."))
                )
            } else {
                List(model.snapshot.items) { item in
                    TimelineRow(item: item, openInCami: openInCami)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle(String(localized: "Today"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(model: model)
                } label: {
                    Label(String(localized: "Settings"), systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
}

private struct DayHeaderView: View {
    let selectedDate: Date
    let goPrevious: () -> Void
    let goNext: () -> Void

    var body: some View {
        HStack {
            Button(action: goPrevious) {
                Label(String(localized: "Previous day"), systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)

            Spacer()

            Text(selectedDate, format: .dateTime.weekday(.wide).day().month())
                .font(.title2.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(action: goNext) {
                Label(String(localized: "Next day"), systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct PermissionBannerView: View {
    @Bindable var model: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !model.hasCalendarAccess {
                PermissionCallout(
                    title: String(localized: "Calendar access needed"),
                    description: String(localized: "Grant access to show events in the timeline."),
                    actionTitle: String(localized: "Grant Calendar Access")
                ) {
                    Task { await model.requestCalendarAccess() }
                }
            }

            if !model.hasRemindersAccess {
                PermissionCallout(
                    title: String(localized: "Reminders access needed"),
                    description: String(localized: "Grant access to show and complete reminders."),
                    actionTitle: String(localized: "Grant Reminders Access")
                ) {
                    Task { await model.requestRemindersAccess() }
                }
            }
        }
    }
}

private struct PermissionCallout: View {
    let title: String
    let description: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct TimelineRow: View {
    let item: TimelineItem
    let openInCami: Bool

    var body: some View {
        Link(destination: item.destinationURL(openInCami: openInCami)) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: item.colorHex))
                    .frame(width: 10, height: 10)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(item.timeLabel)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.subtitle), \(item.timeLabel)")
    }
}

private struct SettingsView: View {
    @Bindable var model: AppViewModel
    @AppStorage("cami.widget.openInApp")
    private var openInCami = true

    var body: some View {
        Form {
            Section(String(localized: "Widget Navigation")) {
                Toggle(String(localized: "Open in Cami"), isOn: $openInCami)
                Text(String(localized: "When disabled, widget taps open Calendar or Reminders."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(String(localized: "Widgets")) {
                Button(String(localized: "Refresh Widgets")) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                Link(String(localized: "How to add and edit widgets on iPhone"), destination: URL(string: "https://support.apple.com/en-us/HT207122")!)
            }
        }
        .navigationTitle(String(localized: "Settings"))
    }
}

private struct OnboardingFlowView: View {
    @Bindable var model: AppViewModel
    let complete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(String(localized: "Welcome to Cami"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(String(localized: "A widgets-first calendar that helps you understand and act on your day quickly."))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                PermissionCallout(
                    title: String(localized: "Calendar"),
                    description: String(localized: "Needed for event timeline and widget content."),
                    actionTitle: String(localized: "Grant Calendar Access")
                ) {
                    Task { await model.requestCalendarAccess() }
                }

                PermissionCallout(
                    title: String(localized: "Reminders"),
                    description: String(localized: "Needed for reminders and completion actions."),
                    actionTitle: String(localized: "Grant Reminders Access")
                ) {
                    Task { await model.requestRemindersAccess() }
                }

                PermissionCallout(
                    title: String(localized: "Contacts"),
                    description: String(localized: "Optional. Used for enriched birthday display."),
                    actionTitle: String(localized: "Grant Contacts Access")
                ) {
                    Task { await model.requestContactsAccess() }
                }

                Button(String(localized: "Continue")) {
                    complete()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint(String(localized: "Finish onboarding and open the app."))
            }
            .padding()
            .navigationTitle(String(localized: "Onboarding"))
        }
    }
}

protocol TimelineRepository: Sendable {
    var calendarAuthorizationStatus: PermissionState { get async }
    var remindersAuthorizationStatus: PermissionState { get async }
    var contactsAuthorizationStatus: PermissionState { get async }

    func requestCalendarAccess() async -> Bool
    func requestRemindersAccess() async -> Bool
    func requestContactsAccess() async -> Bool

    func fetchDaySnapshot(for date: Date, showEvents: Bool, showReminders: Bool) async throws -> DaySnapshot
}

enum PermissionState: Sendable {
    case notDetermined
    case denied
    case authorized
}

actor EventKitTimelineRepository: TimelineRepository {
    private let eventStore = EKEventStore()
    private let contactStore = CNContactStore()

    var calendarAuthorizationStatus: PermissionState {
        get async {
            switch EKEventStore.authorizationStatus(for: .event) {
            case .authorized, .fullAccess, .writeOnly:
                .authorized
            case .denied, .restricted:
                .denied
            case .notDetermined:
                .notDetermined
            @unknown default:
                .denied
            }
        }
    }

    var remindersAuthorizationStatus: PermissionState {
        get async {
            switch EKEventStore.authorizationStatus(for: .reminder) {
            case .authorized, .fullAccess, .writeOnly:
                .authorized
            case .denied, .restricted:
                .denied
            case .notDetermined:
                .notDetermined
            @unknown default:
                .denied
            }
        }
    }

    var contactsAuthorizationStatus: PermissionState {
        get async {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized, .limited:
                .authorized
            case .denied, .restricted:
                .denied
            case .notDetermined:
                .notDetermined
            @unknown default:
                .denied
            }
        }
    }

    func requestCalendarAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    func requestRemindersAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToReminders()
        } catch {
            return false
        }
    }

    func requestContactsAccess() async -> Bool {
        do {
            return try await contactStore.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    func fetchDaySnapshot(for date: Date, showEvents: Bool, showReminders: Bool) async throws -> DaySnapshot {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        var items: [TimelineItem] = []

        if showEvents {
            let eventCalendars = eventStore.calendars(for: .event)
            let predicate = eventStore.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: eventCalendars)
            let events = eventStore.events(matching: predicate)
                .sorted { $0.startDate < $1.startDate }

            items += events.map { event in
                TimelineItem(
                    id: event.calendarItemIdentifier,
                    kind: .event,
                    title: event.title ?? String(localized: "Untitled Event"),
                    subtitle: event.isAllDay ? String(localized: "All-day") : (event.location ?? String(localized: "Event")),
                    date: event.startDate,
                    timeLabel: event.isAllDay ? String(localized: "All-day") : event.startDate.formatted(date: .omitted, time: .shortened),
                    colorHex: event.calendar.hexColor,
                    sourceIdentifier: event.calendarItemIdentifier
                )
            }
        }

        if showReminders {
            let reminderCalendars = eventStore.calendars(for: .reminder)
            let predicate = eventStore.predicateForReminders(in: reminderCalendars)
            let reminders = await withCheckedContinuation { continuation in
                eventStore.fetchReminders(matching: predicate) { reminders in
                    continuation.resume(returning: reminders ?? [])
                }
            }

            items += reminders
                .filter { !$0.isCompleted }
                .compactMap { reminder -> TimelineItem? in
                    guard let dueDate = reminder.dueDateComponents?.date else {
                        return nil
                    }
                    guard dueDate >= dayStart && dueDate < dayEnd else {
                        return nil
                    }

                    return TimelineItem(
                        id: reminder.calendarItemIdentifier,
                        kind: .reminder,
                        title: reminder.title ?? String(localized: "Untitled Reminder"),
                        subtitle: String(localized: "Reminder"),
                        date: dueDate,
                        timeLabel: dueDate.formatted(date: .omitted, time: .shortened),
                        colorHex: reminder.calendar.hexColor,
                        sourceIdentifier: reminder.calendarItemIdentifier
                    )
                }
        }

        let sortedItems = items.sorted { $0.date < $1.date }
        return DaySnapshot(items: sortedItems)
    }
}

struct DaySnapshot: Sendable {
    let items: [TimelineItem]

    static let empty = DaySnapshot(items: [])
}

struct TimelineItem: Identifiable, Hashable, Sendable {
    enum Kind: UInt8, Sendable {
        case event
        case reminder
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let date: Date
    let timeLabel: String
    let colorHex: String
    let sourceIdentifier: String

    func destinationURL(openInCami: Bool) -> URL {
        switch kind {
        case .event:
            if openInCami {
                return URL(string: "camical://event/\(sourceIdentifier)")!
            }
            return URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")!
        case .reminder:
            if openInCami {
                return URL(string: "camical://reminder/\(sourceIdentifier)")!
            }
            return URL(string: "x-apple-reminderkit://remitem/\(sourceIdentifier)")!
        }
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private extension EKCalendar {
    var hexColor: String {
        guard let components = cgColor.components else {
            return "#6D6D6D"
        }

        let red = Int((components[safe: 0] ?? 0.43) * 255)
        let green = Int((components[safe: 1] ?? 0.43) * 255)
        let blue = Int((components[safe: 2] ?? 0.43) * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
