//
//  WidgetFamily.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import WidgetKit

extension WidgetFamily {
    public static func isSmall(_ widgetFamily: WidgetFamily) -> Bool {
        widgetFamily == .systemSmall
    }

    var isSmall: Bool {
        self == .systemSmall
    }
}
