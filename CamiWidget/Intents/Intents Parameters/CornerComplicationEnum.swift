//
//  CornerComplicationEnum.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import Foundation
import AppIntents

enum CornerComplicationEnum: String, CaseIterable, AppEnum {
    typealias RawValue = String

    case hidden      = "Hidden"
    case birthdays   = "Birthdays"
    case summary     = "Summary"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static var caseDisplayRepresentations: [CornerComplicationEnum: DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .birthdays: .init(stringLiteral: "Birthdays"),
        .summary: .init(stringLiteral: "Summary")
    ]

    var title: String {
        self.rawValue
    }
}

struct CornerComplicationOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [CornerComplicationEnum] {
        CornerComplicationEnum.allCases
    }
}
