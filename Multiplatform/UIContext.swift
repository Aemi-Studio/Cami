//
//  ViewContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import Collections
import Contacts
import EventKit
import Foundation
import SwiftUI

@Observable
@MainActor final class UIContext: Loggable {
    static let shared: UIContext = .init(for: .now)

    public func reset() {
        calendars = Set(DataContext.shared.allCalendars.asIdentifiers)
    }

    public var date: Date
    public var path: NavigationPath
    public var calendars: Set<String> = Set(DataContext.shared.allCalendars.asIdentifiers)

    init(for date: Date = .now) {
        self.date = date
        self.path = .init()
    }

}

extension EnvironmentValues {
    @Entry var views: UIContext!
}
