//
//  CustomDisclosureGroupStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 31/03/25.
//

import SwiftUI

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    @Binding private(set) var track: Bool

    init(track state: Binding<Bool>? = nil) {
        _track = state ?? .constant(false)
    }

    func makeBody(configuration: Configuration) -> some View {
        CustomSection {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer()
                    Label("Toggle", systemImage: configuration.isExpanded ? "chevron.up" : "chevron.down")
                        .labelStyle(.iconOnly)
                        .font(.headline)
                }
                .contentShape(.rect)
            }.buttonStyle(.plain)
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                configuration.content
                    .frame(alignment: .top)
                    .clipped()
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxHeight: configuration.isExpanded ? .infinity : 0, alignment: .top)
            .opacity(configuration.isExpanded ? 1 : 0)
        }
        .padding(.bottom, configuration.isExpanded ? 0 : -16)
        .animation(.default, value: configuration.isExpanded)
        .onAppear {
            track = configuration.isExpanded
        }
        .onChange(of: configuration.isExpanded) { _, newValue in
            if track != newValue {
                track = newValue
            }
        }
    }
}
