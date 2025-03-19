//
//  TopBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import SwiftUI

struct TopBar<LeadingContent: View, TrailingContent: View>: View {

    private let font: Font
    private let height: CGFloat
    private let leadingContent: () -> LeadingContent
    private let trailingContent: () -> TrailingContent

    init(
        font: Font = .largeTitle,
        height: CGFloat,
        @ViewBuilder leading: @escaping () -> LeadingContent,
        @ViewBuilder trailing: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.font = font
        self.height = height
        self.leadingContent = leading
        self.trailingContent = trailing
    }

    var body: some View {
        HStack(alignment: .center) {
            leadingContent()
                .font(font)

            Spacer()

            HStack(spacing: height == 48 ? 4 : 0) {
                trailingContent()
            }
            .buttonStyle(CircularGlassButtonStyle(height))
            .padding(.trailing, height == 48 ? -4 : -8)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
    }
}
