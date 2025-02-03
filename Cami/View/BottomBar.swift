//
//  BottomBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct BottomBar: View {
    @Environment(\.presentation) private var presentation
    @Environment(\.path) private var path

    var body: some View {
        if let controller = path?.controller, let presentation {
            @Bindable var presentation = presentation

            bottomBarButtons
                .animation(.spring, value: controller.scrollPosition)
                .update($presentation.bottomBarSize)
                .safeAreaPadding(.bottom)
        }
    }

    @ViewBuilder var slidingIndicator: some View {
        if let path, let controller = path.controller {
            HStack(spacing: 4) {
                ForEach(path.path) { page in
                    Capsule()
                        .frame(width: controller.scrollPosition == page ? 32 : 8, height: 8)
                }
            }
        }
    }

    @ViewBuilder
    var bottomBarButtons: some View {
        if let path, let controller = path.controller {
            HStack(spacing: 8) {
                ForEach(path.path) { page in
                    Button {
                        withAnimation {
                            controller.scrollPosition = page
                        }
                    } label: {
                        Image(systemName: "circle")
                            .foregroundStyle(.clear)
                            .overlay {
                                Label(page.localizedDescription, systemImage: page.icon)
                                    .foregroundStyle(Color.primary)
                                    .labelStyle(.iconOnly)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(.rect(cornerRadius: 8))
                            .thinBorder(radius: 8)
                    }
                }

                ReminderCreationButton()

                SettingsButton()
            }
            .padding(8)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12))
            .thinBorder(radius: 12)
        }
    }
}

struct SettingsButton: View {
    @Environment(\.presentation) private var presentation

    var body: some View {
        Button {
            withAnimation {
                presentation?.toggleMenu(.settings)
            }
        } label: {
            Image(systemName: "circle")
                .foregroundStyle(.clear)
                .overlay {
                    Label("Settings", systemImage: "gear")
                        .foregroundStyle(Color.primary)
                        .labelStyle(.iconOnly)
                        .fontWeight(.medium)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 8))
                .thinBorder(radius: 8)
        }
    }
}
