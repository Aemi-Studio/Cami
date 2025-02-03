//
//  AccessCheckbox.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import AemiUI
import SwiftUI

struct AccessCheckbox: View {

    let status: Access.Status

    private var tint: Color? {
        .accentColor
    }

    private func symbol(for status: Access.Status) -> CheckboxSymbol? {
        switch status {
        case .none, .notDetermined: nil
        case .restricted: .xmark
        case .authorized: .checkmark
        }
    }

    private func backgroundStyle(for status: Access.Status) -> any ShapeStyle {
        switch status {
        case .none, .notDetermined: .gray.secondary
        case .restricted: .red
        case .authorized: tint ?? .green
        }
    }

    var body: some View {
        ObservingCheckbox(
            value: status,
            symbolProvider: symbol,
            backgroundStyleProvider: backgroundStyle
        )
    }
}
