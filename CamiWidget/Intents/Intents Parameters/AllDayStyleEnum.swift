//
//  AllDayStyleEnum.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 17/11/23.
//

import AppIntents
import Foundation

enum AllDayStyleEnum: String, CaseIterable, AppEnum, WidgetEnumParameter {
    typealias RawValue = String

    case hidden = "Hidden"
    case event = "Event"
    case bordered = "Event Bordered"

    static let localizedTitle = String(localized: "intentParameter.allDayStyle.title")

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static var caseDisplayRepresentations: [AllDayStyleEnum: DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .event: .init(stringLiteral: "Event"),
        .bordered: .init(stringLiteral: "Event Bordered")
    ]

    var title: String {
        rawValue
    }
}

struct AllDayStyleOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [AllDayStyleEnum] {
        AllDayStyleEnum.allCases
    }
}
