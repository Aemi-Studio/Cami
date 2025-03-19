//
//  PresentationContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import EventKit
import SwiftUI

@Observable
final class PresentationContext {
    static let shared: PresentationContext = .init()

    var areInformationsPresented: Bool = false
    var areSettingsPresented: Bool {
        get { menu == .settings }
        set { if newValue { menu = .settings } else { menu = .none } }
    }
    var isCreationSheetPresented: Bool {
        get {
            if case .new = menu {
                true
            } else {
                false
            }
        }
        set {
            if newValue {
                menu = .new()
            } else {
                menu = .none
            }
        }
    }
    var isWidgetPreviewSheetPresented: Bool = false

    var topBarSize: CGSize? = .zero
    var bottomBarSize: CGSize? = .zero
    var keyboardSize: CGFloat? = .zero

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
        case widgets
        case new(item: EKCalendarItem? = nil)
        case none

        var description: String {
            switch self {
            case .settings:
                return "Settings"
            case .widgets:
                return "Widgets"
            case let .new(item):
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

        var value: EKCalendarItem? {
            switch self {
            case let .new(item):
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
    @Entry var presentation: PresentationContext = .shared
}
