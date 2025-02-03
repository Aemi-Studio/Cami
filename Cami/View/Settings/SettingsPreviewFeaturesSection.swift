//
//  SettingsPreviewFeaturesSection.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct SettingsPreviewFeaturesSection: View {

    @AppStorage(SettingsKeys.accessWorkInProgressFeatures)
    private var accessWorkInProgressFeatures: Bool = false

    private var accessWorkInProgressFeaturesBinding: Binding<Bool> {
        Binding {
            accessWorkInProgressFeatures
        } set: {
            accessWorkInProgressFeatures = $0
        }
    }

    @State private var isWipPopoverPresented: Bool = false

    var body: some View {
        CustomSection {
            Label(
                String(localized: "settings.section.advanced.header"),
                systemImage: "exclamationmark.circle.fill"
            )
        } content: {
            CustomBordered(backgroundStyle: Color.secondary, outline: true) {
                Toggle(isOn: accessWorkInProgressFeaturesBinding) {
                    HStack {
                        Text(String(localized: "settings.features.wip.title"))
                        Label(String(localized: "More informations"), systemImage: "info.circle")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .toggleStyle(.nativeCheckbox(placement: .trailing))
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                isWipPopoverPresented.toggle()
            }
            .autosizingPopover(isPresented: $isWipPopoverPresented, fixedSize: .vertical) {
                Text(String(localized: "settings.section.features.footer"))
                    .padding()
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
        }
    }
}
