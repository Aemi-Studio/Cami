//
//  PresentationContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

@Observable
@MainActor final class PresentationContext {

    static let shared: PresentationContext = .init()

    var areInformationsPresented: Bool = false
    var areSettingsPresented: Bool = false
    var isReminderCreationSheetPresented: Bool = false
}

extension EnvironmentValues {
    @Entry var presentation: PresentationContext?
}
