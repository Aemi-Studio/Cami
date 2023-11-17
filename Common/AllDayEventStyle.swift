//
//  AllDayEventStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import Foundation
import AppIntents

enum AllDayEventStyle: String, CaseIterable, AppEnum {
    typealias RawValue = String

    case hidden = "Hidden"
    case inline = "Inline"
    case event  = "Event"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Style")

    static var caseDisplayRepresentations: [AllDayEventStyle : DisplayRepresentation] = [
        .hidden: .init(stringLiteral: "Hidden"),
        .inline: .init(stringLiteral: "Inline"),
        .event: .init(stringLiteral: "Event")
    ]

    var title: String {
        self.rawValue
    }


}
