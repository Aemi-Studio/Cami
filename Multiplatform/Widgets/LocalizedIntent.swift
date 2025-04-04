//
//  LocalizedIntent.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import AppIntents

protocol LocalizedIntent {
    static var localizedTitle: String { get }
}

protocol WidgetParameter: LocalizedIntent {}

protocol WidgetEnumParameter: WidgetParameter, Hashable, RawRepresentable
where RawValue : Hashable {
    static var allCases: [Self] { get }
}
