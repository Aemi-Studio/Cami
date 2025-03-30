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
    
    var description: String {
        switch rawValue {
            case .systemSmall:
                String(localized: "WidgetFamily.Small.Name")
            case .systemMedium:
                String(localized: "WidgetFamily.Medium.Name")
            case .systemLarge:
                String(localized: "WidgetFamily.Large.Name")
            case .systemExtraLarge:
                String(localized: "WidgetFamily.ExtraLarge.Name")
            case .accessoryCorner:
                String(localized: "WidgetFamily.AccessoryCorner.Name")
            case .accessoryCircular:
                String(localized: "WidgetFamily.AccessoryCircular.Name")
            case .accessoryRectangular:
                String(localized: "WidgetFamily.AccessoryRectangular.Name")
            case .accessoryInline:
                String(localized: "WidgetFamily.AccessoryInline.Name")
            @unknown default:
                String(localized: "WidgetFamily.Unknown.Name")
        }
    }
}

extension EnvironmentValues {
    @Entry var customWidgetFamily: CustomWidgetFamily?
}
