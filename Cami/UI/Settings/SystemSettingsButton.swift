//
//  SystemSettingsButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct SystemSettingsButton: View {
    var body: some View {
        Button(
            String(localized: "settings.navigationlink.openSettings"),
            systemImage: "gear"
        ) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        .buttonStyle(.accentOverSecondaryWithOutline)
    }
}
