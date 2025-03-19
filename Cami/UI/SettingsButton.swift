//
//  SettingsButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import SwiftUI

struct SettingsButton: View {
    @Environment(\.presentation) private var presentation

    var body: some View {
        Button {
            withAnimation {
                presentation.toggleMenu(.settings)
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
