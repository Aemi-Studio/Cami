//
//  SettingsNavigationLinksSection.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct SettingsNavigationLinksSection: View {
    @Environment(AppNavigation.self) private var navigation
    
    var body: some View {
        CustomSection {
            Label(
                String(localized: "settings.section.general.header"),
                systemImage: "gear"
            )
        } content: {
            NavigationLink(value: NavigationDestination.knowledgeBase) {
                Text(String(localized: "knowledgebase.navigationlink.title"))
            }

            NavigationLink(value: NavigationDestination.permissions) {
                Text(String(localized: "permissions.navigationlink.title"))
            }

            NavigationLink(value: NavigationDestination.widgetSettings) {
                Text(String(localized: "widgetSettings.navigationlink.title"))
            }
            
            #if DEBUG
            NavigationLink(value: NavigationDestination.developer) {
                Text(String(localized: "view.developer.title"))
            }
            #endif
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
