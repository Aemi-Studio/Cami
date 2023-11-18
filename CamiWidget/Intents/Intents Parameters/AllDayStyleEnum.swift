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

    case hidden = "Hidden"
    case inline = "Inline"
    case event  = "Event"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static var caseDisplayRepresentations: [AllDayStyleEnum : DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .inline: .init(stringLiteral: "Inline"),
        .event: .init(stringLiteral: "Event")
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
