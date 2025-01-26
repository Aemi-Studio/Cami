//
//  Page.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI
import EventKit
import Contacts

enum Page: Identifiable, Hashable {

    var id: String {
        self.localizedDescription
    }

    case onboarding
    case settings
    case permissions
    case day(Date)
    //    case event(EKEvent)
    //    case contact(CNContact)
}

extension Page {

    var localizedDescription: String {
        switch self {
        case .onboarding:
            return "Onboarding"
        case .day(let date):
            return String(describing: date)
        case .settings:
            return "Settings"
        case .permissions:
            return "Permissions"
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
        case .day:
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
            case .day(let date):
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

struct CustomSettingsView: View {
    var body: some View {
        ScrollView(.vertical) {
            Text("Settings")
        }
    }
}
