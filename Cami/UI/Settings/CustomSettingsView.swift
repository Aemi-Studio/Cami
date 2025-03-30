//
//  CustomSettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/01/25.
//

import SwiftUI
import WidgetKit

struct CustomSettingsView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                SettingsNavigationLinksSection()
                SettingsPreviewFeaturesSection()
                CustomSection {
                    WidgetTutorialButton()
                    PrivacyPolicyButton()
                }
                CustomSection {
                    SystemSettingsButton()
                }
            }
            .padding(.horizontal)
        }
        .scrollBounceBehavior(.always)
        .scrollClipDisabled()
        .navigationTitle(String(localized: "settings.navigation.title"))
    }
}

extension View {
    @ViewBuilder func containerNavigationBackground() -> some View {
        if #available(iOS 18.0, *) {
            containerBackground(.clear, for: .navigation)
        } else {
            background()
        }
    }
}
