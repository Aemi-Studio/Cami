//
//  TopBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import SwiftUI

struct TopBar<LeadingContent: View, TrailingContent: View>: View {

    private let height: CGFloat
    private let leadingContent: () -> LeadingContent
    private let trailingContent: () -> TrailingContent

    @ScaledMetric private var title3FontSize: CGFloat = 20
    @ScaledMetric private var largeTitleFontSize: CGFloat = 34

    private let heightRange: (CGFloat, CGFloat) = (48.0, 32.0)
    private var fontSizeRange: (CGFloat, CGFloat) { (largeTitleFontSize, title3FontSize) }
    private let spacingRange: (CGFloat, CGFloat) = (4.0, 0.0)
    private let paddingRange: (CGFloat, CGFloat) = (-4.0, -8.0)

    init(
        height: CGFloat,
        @ViewBuilder leading: @escaping () -> LeadingContent,
        @ViewBuilder trailing: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.height = height
        self.leadingContent = leading
        self.trailingContent = trailing
    }

    var body: some View {
        HStack(alignment: .center) {
            leadingContent()
                .font(.system(size: height.mapped(from: heightRange, to: fontSizeRange)))

            Spacer()

            HStack(spacing: height.mapped(from: heightRange, to: spacingRange)) {
                trailingContent()
            }
            .buttonStyle(CircularGlassButtonStyle(height))
            .padding(.trailing, height.mapped(from: heightRange, to: paddingRange))
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .animation(.default, value: height)
    }
}
