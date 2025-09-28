//
//  AccessCheckbox.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import AemiUI
import SwiftUI

struct AccessCheckbox: View {
    let status: PermissionStatus

    private var tint: Color? {
        .accentColor
    }

    private func symbol(for status: PermissionStatus) -> CheckboxSymbol? {
        switch status {
            case .notDetermined: nil
            case .restricted, .denied: .xmark
            case .authorized: .checkmark
        }
    }

    private func backgroundStyle(for status: PermissionStatus) -> any ShapeStyle {
        switch status {
            case .notDetermined: .gray.secondary
            case .denied: .red
            case .restricted: .purple
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
