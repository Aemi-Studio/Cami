//
//  Page.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import Contacts
import EventKit
import SwiftUI

enum Page: Identifiable, Hashable {
    var id: String {
        localizedDescription
    }

    case onboarding
    case settings
    case permissions
    case today
    case day(Date)
    //    case event(EKEvent)
    //    case contact(CNContact)
}

extension Page {
    var localizedDescription: String {
        switch self {
        case .onboarding:
            "Onboarding"
        case .today:
            String(describing: Date.now)
        case let .day(date):
            String(describing: date)
        case .settings:
            "Settings"
        case .permissions:
            "Permissions"
        }
    }

    var icon: String {
        switch self {
        case .onboarding:
            "door.left.hand.open"
        case .settings:
            "gear"
        case .permissions:
            "shield"
        case .today, .day:
            "calendar"
        }
    }
}

extension Page: Equatable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
}

extension Page {
    @ViewBuilder
    func callAsFunction() -> some View {
        Group {
            switch self {
            case .onboarding:
                OnboardingView()
            case .today:
                TodayView()
            case let .day(date):
                SingleDayView(date: date)
            case .settings:
                CustomSettingsView()
            case .permissions:
                PermissionsView()
            }
        }
        .page(self)
    }
}
