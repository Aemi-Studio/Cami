//
//  CamiWidgetView.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 05/11/23.
//

import AemiUI
import AemiSDR
import SwiftUI

struct CamiWidgetView: View {
    typealias Entry = StandardWidgetEntry
    typealias Content = StandardWidgetContent

    @Environment(\.colorScheme)
    private var colorScheme

    private let content: Content

    private var showHeader: Bool { content.configuration.showHeader }

    private var background: some ShapeStyle {
        AnyShapeStyle(Color.background.opacity(0.9))
    }

    init(for entry: Entry) {
        self.content = entry.content
    }

    var body: some View {
        VStack(spacing: 6) {
            if showHeader {
                CamiWidgetHeader()
            }
            Color.clear.overlay(alignment: .top) {
                CamiWidgetEvents()
                    .frame(alignment: .top)
                    .padding(.top, showHeader ? 0 : 6)
            }
            Spacer(minLength: 0)
        }
        .padding([.top, .horizontal], 6)
        .accessibilityAddTraits(.updatesFrequently)
        .mask { maskContent }
        .widgetAccentable()
        .containerBackground(background, for: .widget)
        .environment(\.widgetContent, content)
        .environment(\.data, .shared)
        .environment(\.locale, .prefered)
    }
    
    private var maskContent: some View {
        VStack(spacing: 0) {
            Color.black
            GradientMask(direction: .down)
                .frame(height: 24)
        }
    }
}
