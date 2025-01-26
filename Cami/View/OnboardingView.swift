//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

struct OnboardingView: View {

    @Environment(\.presentation) private var presentation
    @Environment(\.permissions) private var permissions

    private var authorized: Bool {
        permissions?.global == .authorized
    }

    private var restricted: Bool {
        permissions?.global == .restricted
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {

                header

                footer

            }
            .lineLimit(10)
            .padding()
        }
    }

    var header: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 32)
            VStack {
                Text("Welcome to")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Cami Calendar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Spacer(minLength: 32)
            Text("""
        Cami Calendar, in its current version, is only a widget.
        We propose it as a better and improved way to display your current native calendar content on your homescreen.
        """)
            Spacer(minLength: 32)
            if !authorized {
                if restricted {
                    Button {
                        AppContext.open(.settings)
                    } label: {
                        ButtonInnerBody(
                            label: "Restricted",
                            description: "Review Cami access to data.",
                            systemImage: "gear",
                            radius: 8,
                            border: true
                        )
                        .tint(.red)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text("Set Up Cami")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.tint)
                                Spacer()
                            }
                            HStack {
                                Text("""
    Cami needs access to your calendars to work properly.
    It can also use your contacts information to display birthdays in widgets.
    """)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.tint.opacity(0.8))

                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.leading)

                        Button {
                            presentation?.areSettingsPresented.toggle()
                        } label: {
                            ButtonInnerBody(
                                label: "Continue",
                                systemImage: "arrow.forward.square",
                                radius: 8,
                                border: false,
                                opacity: 1
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial.opacity(0.5))
                    .background(.tint.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.tint, lineWidth: 0.5)
                            .foregroundStyle(.clear)
                    }
                }
            } else {
                ButtonInnerBody(
                    label: "Everything is fine.",
                    description: "Stay tuned for next Cami updates.",
                    radius: 8,
                    alignment: .center,
                    noIcon: true
                )
                .tint(.green)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            Button("Refresh Widgets", systemImage: "arrow.clockwise") {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    @ViewBuilder
    var footer: some View {
        WidgetHelpView(
            title: "How to add and edit widgets on iPhone",
            url: "https://support.apple.com/en-us/HT207122",
            description: "Visit Apple Support."
        )

        Button {
            presentation?.areInformationsPresented.toggle()
        } label: {
            ButtonInnerBody(
                label: "Information",
                description: "Understand how Cami works.",
                systemImage: "info.circle"
            )
            .tint(.blue)
        }

        Button {
            presentation?.areSettingsPresented.toggle()
        } label: {
            ButtonInnerBody(
                label: "Permissions",
                description: "Check what Cami can access.",
                systemImage: "hand.raised.square"
            )
            .tint(.blue)
        }

        WidgetHelpView(
            title: "Privacy Policy",
            url: "https://aemi.studio/privacy",
            description: "Review how Cami handles your data."
        )

        SettingsLinkView()
    }
}
