//
//  SettingsNavigationLinksSection.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct SettingsNavigationLinksSection: View {

    var body: some View {
        CustomSection {
            Label(
                String(localized: "settings.section.general.header"),
                systemImage: "gear"
            )
        } content: {
            NavigationPageLink(String(localized: "knowledgebase.navigationlink.title")) {
                KnowledgeBaseView()
            }

            NavigationPageLink(String(localized: "permissions.navigationlink.title")) {
                PermissionsView()
            }

            WidgetsRefreshButton()
        }
    }
}
