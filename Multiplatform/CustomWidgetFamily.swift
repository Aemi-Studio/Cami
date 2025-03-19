//
//  CustomWidgetFamily.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import SwiftUI
import WidgetKit

final class CustomWidgetFamily {
    let rawValue: WidgetFamily
    init(_ value: WidgetFamily) {
        self.rawValue = value
    }
}

extension EnvironmentValues {
    @Entry var customWidgetFamily: CustomWidgetFamily?
}
