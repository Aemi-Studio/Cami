//
//  AccessCheckbox.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

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

    private func backgroundColor(for status: Access.Status) -> Color {
        switch status {
        case .none, .notDetermined: .gray
        case .restricted:           .red
        case .authorized:           tint ?? .green
        }
    }

    var body: some View {
        ObservingCheckbox(
            value: status,
            symbolProvider: symbol,
            backgroundColorProvider: backgroundColor
        )
    }
}
