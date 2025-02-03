//
//  PresentationContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI
import EventKit

@Observable
@MainActor final class PresentationContext {

    static let shared: PresentationContext = .init()

    var areInformationsPresented: Bool = false
    var areSettingsPresented: Bool = false
    var isReminderCreationSheetPresented: Bool = false

    var bottomBarSize: CGSize? = .zero

    var menu: MenuPane = .none
    var isMenuPresented: Bool {
        menu != .none
    }

    func toggleMenu(_ pane: MenuPane) {
        withAnimation {
            if menu == pane {
                menu = .none
            } else {
                menu = pane
            }
        }
    }

    enum MenuPane: Equatable {
        case settings
        case new(item: CItem?)
        case none

        var description: String {
            switch self {
            case .settings:
                return "Settings"
            case .new(let item):
                var start = "New"
                switch item {
                case is EKEvent: start += " Event\(" " + (item?.calendarItemIdentifier ?? ""))"
                case is EKReminder: start += " Reminder\(" " + (item?.calendarItemIdentifier ?? ""))"
                default: break
                }
                return start
            case .none:
                return "None"
            }
        }

        var value: CItem? {
            switch self {
            case .new(let item):
                return item
            default:
                return nil
            }
        }

        static func == (lhs: PresentationContext.MenuPane, rhs: PresentationContext.MenuPane) -> Bool {
            lhs.description == rhs.description && lhs.value == rhs.value
        }
    }
}

extension EnvironmentValues {
    @Entry var presentation: PresentationContext?
}
