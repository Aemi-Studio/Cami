//
//  ComplicationEnum.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import AppIntents
import Foundation

enum ComplicationEnum: String, CaseIterable, AppEnum, WidgetEnumParameter {
    typealias RawValue = String

    case hidden = "Hidden"
    case birthdays = "Birthdays"
    case summary = "Summary"

    static let localizedTitle = String(localized: "intentParameter.complication.title")

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static let caseDisplayRepresentations: [ComplicationEnum: DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .birthdays: .init(stringLiteral: "Birthdays"),
        .summary: .init(stringLiteral: "Summary")
    ]

    var title: String {
        rawValue
    }
}

struct ComplicationOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [ComplicationEnum] {
        ComplicationEnum.allCases
    }
}
