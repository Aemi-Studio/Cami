//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

struct OnboardingView: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    @Environment(PermissionModel.self)
    private var perms: PermissionModel

    @Binding
    var areSettingsPresented: Bool

    @Binding
    var areInformationsPresented: Bool

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures = false

    private var authorized: Bool {
        return if accessWorkInProgressFeatures {
            perms.global == ._beta_authorized
        } else {
            perms.global.isSuperset(of: .authorized)
        }
    }

    private var restricted: Bool {
        return if accessWorkInProgressFeatures {
            !perms.global.isDisjoint(with: .restricted)
        } else {
            !perms.global.isDisjoint(with: [.restrictedCalendars, .restrictedContacts])
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {

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
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
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
                                    areSettingsPresented.toggle()
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
                WidgetHelpView(
                    title: "How to add and edit widgets on iPhone",
                    url: "https://support.apple.com/en-us/HT207122",
                    description: "Visit Apple Support."
                )

                Button {
                    areInformationsPresented.toggle()
                }label: {
                    ButtonInnerBody(
                        label: "Information",
                        description: "Understand how Cami works.",
                        systemImage: "info.circle"
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
            .lineLimit(10)
            .padding()
        }
    }
}
