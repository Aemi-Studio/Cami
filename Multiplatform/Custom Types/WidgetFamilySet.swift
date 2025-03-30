//
//  WidgetFamilySet.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import WidgetKit

struct WidgetFamilySet: OptionSet, Hashable {
    let rawValue: Int

    static let systemSmall = WidgetFamilySet(rawValue: 1 << 0)
    static let systemMedium = WidgetFamilySet(rawValue: 1 << 1)
    static let systemLarge = WidgetFamilySet(rawValue: 1 << 2)
    static let systemExtraLarge = WidgetFamilySet(rawValue: 1 << 3)

    static let notSmall: WidgetFamilySet = [
        .systemMedium,
        .systemLarge,
        .systemExtraLarge
    ]

    static let all: WidgetFamilySet = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .systemExtraLarge
    ]

    static let none: WidgetFamilySet = []
}

extension WidgetFamilySet {
    public static func convert(_ widgetFamily: WidgetFamily) -> WidgetFamilySet {
        switch widgetFamily {
            case .systemExtraLarge: .systemExtraLarge
            case .systemLarge: .systemLarge
            case .systemMedium: .systemMedium
            case .systemSmall: .systemSmall
            default: .none
        }
    }
}
