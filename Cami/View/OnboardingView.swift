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
    private var viewModel: ViewModel

    @Binding
    var authorized: Bool

    @Binding
    var restricted: Bool

    @Binding
    var isModalPresented: Bool

    @Binding
    var isInformationModalPresented: Bool

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
                            Button {
                                isModalPresented.toggle()
                            } label: {
                                ButtonInnerBody(
                                    label: "Grant Access",
                                    description: "Cami needs you to grant it access to your calendar and contacts information to work properly.",
                                    systemImage: "checkmark.circle.badge.questionmark",
                                    radius: 8,
                                    border: true
                                )
                                .tint(.orange)
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
                    isInformationModalPresented.toggle()
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
