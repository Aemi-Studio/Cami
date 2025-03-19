//
//  PrivacyPolicyButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct PrivacyPolicyButton: View {
    @State private var isPrivacyPolicyPresented: Bool = false

    var body: some View {
        Button(
            String(localized: "Privacy Policy"),
            systemImage: "arrow.up.forward.square"
        ) {
            isPrivacyPolicyPresented.toggle()
        }
        .buttonStyle(
            .customBorderedButton(
                description: String(localized: "Review how Cami handles your data."),
                outline: true
            )
        )
        .sheet(isPresented: $isPrivacyPolicyPresented) {
            SafariView(url: .init(string: "https://aemi.studio/privacy")!)
        }
    }
}
