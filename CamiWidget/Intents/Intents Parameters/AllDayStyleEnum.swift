//
//  AllDayStyleEnum.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 17/11/23.
//

import Foundation
import AppIntents

enum AllDayStyleEnum: String, CaseIterable, AppEnum {
    typealias RawValue = String

    case hidden     = "Hidden"
    case event      = "Event"
    case bordered   = "Event Bordered"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static var caseDisplayRepresentations: [AllDayStyleEnum: DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .event: .init(stringLiteral: "Event"),
        .bordered: .init(stringLiteral: "Event Bordered")
    ]

    var title: String {
        self.rawValue
    }
}

struct AllDayStyleOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [AllDayStyleEnum] {
        AllDayStyleEnum.allCases
    }
}
