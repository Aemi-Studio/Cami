//
//  ModalSheetContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 29/03/25.
//

import EventKit
import SwiftUI

@Observable
final class ModalSheetContext {
    static let shared = ModalSheetContext()

    func open(modal: MenuPane) {
        if menu != .none {
            close()
            Task { [weak self] in
                guard let self else {
                    return
                }
                try? await Task.sleep(for: .milliseconds(200))
                menu = modal
            }
        } else {
            menu = modal
        }
    }

    func close() {
        menu = .none
    }

    var menu: MenuPane = .none
}

enum MenuPane: Equatable {
    case settings
    case widgets
    case permissions
    case new(item: EKCalendarItem? = nil)
    case none

    private static let context = ModalSheetContext.shared

    var bool: Bool {
        get { self == .none ? false : Self.context.menu == self }
        set {
            if self == .none {
                Self.context.close()
            } else {
                if newValue, Self.context.menu != self {
                    Self.context.open(modal: self)
                } else {
                    Self.context.close()
                }
            }
        }
    }

    var description: String {
        switch self {
            case .settings:
                return "Settings"
            case .widgets:
                return "Widgets"
            case .permissions:
                return "Permissions"
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

    var localizedDescription: String {
        String(localized: "\(description)")
    }

    var value: EKCalendarItem? {
        switch self {
            case let .new(item): item
            default: nil
        }
    }

    var view: (() -> any View)? {
        switch self {
            case .settings: CustomSettingsView.init
            case .new: CreateCalendarItemView.init
            case .widgets: WidgetPreviewView.init
            case .permissions: PermissionsView.init
            case .none: nil
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description && lhs.value == rhs.value
    }
}

extension EnvironmentValues {
    @Entry var modal: ModalSheetContext = .shared
    @Entry var openModal: ((MenuPane) -> Void)?
}
