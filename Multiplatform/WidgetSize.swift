//
//  WidgetSize.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import AemiUtilities
import Foundation
import SwiftUI
import WidgetKit

enum WidgetSize: Hashable, Codable, Sendable, Comparable, CaseIterable {
    @MainActor
    static var allCases: [WidgetSize] {
        [.small, .medium, .large] + (Platform.is(.pad) ? [.extraLarge] : [])
    }

    case small
    case medium
    case large
    case extraLarge
}

extension WidgetSize: Identifiable {
    var id: Int {
        hashValue
    }
}

extension WidgetSize {
    @MainActor
    var size: CGSize {
        if Platform.is(.pad) {
            return switch self {
                case .small: CGSize(width: 150, height: 150)
                case .medium: CGSize(width: 327.5, height: 150)
                case .large: CGSize(width: 327.5, height: 327.5)
                case .extraLarge: CGSize(width: 682, height: 327.5)
                @unknown default: .zero
            }
        }
        if Platform.is(.phone) {
            return switch self {
                case .small: CGSize(width: 150, height: 150)
                case .medium: CGSize(width: 327.5, height: 150)
                case .large: CGSize(width: 327.5, height: 327.5)
                default: .zero
            }
        }
        return .zero
    }

    var family: WidgetFamily {
        switch self {
            case .small: .systemSmall
            case .medium: .systemMedium
            case .large: .systemLarge
            case .extraLarge: .systemExtraLarge
        }
    }

    init?(from family: WidgetFamily) {
        switch family {
            case .systemSmall: self = .small
            case .systemMedium: self = .medium
            case .systemLarge: self = .large
            case .systemExtraLarge: self = .extraLarge
            default: return nil
        }
    }

    var custom: CustomWidgetFamily {
        CustomWidgetFamily(self)
    }
}

extension CustomWidgetFamily {
    convenience init(_ size: WidgetSize) {
        self.init(size.family)
    }
}
