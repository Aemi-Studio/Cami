//
//  SettingsLinkView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/02/24.
//

import SwiftUI

struct SettingsLinkView: View {
    var radius: Double?
    var body: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } label: {
            ButtonInnerBody(
                label: "Settings",
                description: "Review Cami access to your data.",
                systemImage: "gear",
                radius: radius
            )
        }

    }
}

#Preview {
    SettingsLinkView()
}
