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

            NavigationPageLink(String(localized: "widgetSettings.navigationlink.title")) {
                WidgetSettingsView()
            }
        }
    }
}

struct WidgetSettingsView: View {
    var body: some View {
        ScrollablePage(title: String(localized: "view.widgetSettings.title")) {
            CustomSection {
                WidgetsRefreshButton()
            }
            
            WidgetPreviewView()
        }
    }
}

struct ScrollablePage<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                content()
            }
            .padding([.horizontal, .top])
        }
        .navigationTitle(title)
    }
}
