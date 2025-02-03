//
//  CustomSettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/01/25.
//

import SwiftUI
import WidgetKit

struct CustomSettingsView: View {

    @Environment(\.presentation) private var presentation

    var body: some View {
        NavigationScroll {
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
                .avoidBottomBar()
                .buttons {
                    Button(
                        String(localized: "settings.overlay.closeButton"),
                        systemImage: "xmark",
                        action: { presentation?.toggleMenu(.settings) }
                    )
                    .tint(Color.primary)
                }
            }
            .scrollBounceBehavior(.always)
            .scrollClipDisabled()
            .setNavigationPage(\.title, to: String(localized: "settings.navigation.title"))
        }
    }
}
