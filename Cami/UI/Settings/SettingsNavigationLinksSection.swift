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
            NavigationPageLink(
                String(localized: "knowledgebase.navigationlink.title"),
                destination: .knowledgeBase
            )

            NavigationPageLink(
                String(localized: "permissions.navigationlink.title"),
                destination: .permissions
            )

            NavigationPageLink(
                String(localized: "widgetSettings.navigationlink.title"),
                destination: .widgetSettings
            )
            
            #if DEBUG
            NavigationPageLink(
                String(localized: "view.developer.title"),
                destination: .developer
            )
            #endif
        }
    }
}

struct WidgetSettingsView: View {
    @AppStorage(SettingsKeys.openInCami.rawValue)
    private var openInCami: Bool = false

    private var openInCamiBinding: Binding<Bool> {
        Binding {
            openInCami
        } set: {
            openInCami = $0
        }
    }

    var body: some View {
        ScrollablePage(title: String(localized: "view.widgetSettings.title")) {
            CustomSection {
                Label(
                    String(localized: "settings.section.widgetNavigation.header"),
                    systemImage: "arrow.up.forward.app"
                )
            } content: {
                BorderedToggle(isOn: openInCamiBinding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "settings.widget.openInCami.title"))
                        Text(String(localized: "settings.widget.openInCami.description"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

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
