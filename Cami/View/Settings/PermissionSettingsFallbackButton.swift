//
//  PermissionSettingsFallbackButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import SwiftUI

struct PermissionSettingsFallbackButton: View {

    var description: String = ""
    var radius: Double? = 8.0

    var body: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } label: {
            ButtonInnerBody(
                label: "Restricted",
                description: description,
                systemImage: "gear",
                radius: radius,
                border: true
            )
            .tint(.red)
        }
    }
}
