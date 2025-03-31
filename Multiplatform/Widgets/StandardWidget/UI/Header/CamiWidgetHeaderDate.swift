//
//  CamiWidgetHeaderDate.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import SwiftUI
import WidgetKit

struct CamiWidgetHeaderDate: View {
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
    @Environment(\.customWidgetFamily) private var customWidgetFamily
    @Environment(\.widgetContent) private var content
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.colorScheme) private var colorScheme

    private var family: WidgetFamily { customWidgetFamily?.rawValue ?? widgetFamily }

    private var dayLength: Date.FormatterKind {
        switch family {
            case .systemExtraLarge: .long
            case .systemSmall: .short
            default: .medium
        }
    }

    private var renderedOpacity: Double {
        switch renderingMode {
            case .accented, .vibrant: 0.5
            default: 1.0
        }
    }

    private var dayColor: some ShapeStyle {
        if colorScheme == .dark {
            AnyShapeStyle(Color.primary.opacity(renderedOpacity))
        } else {
            AnyShapeStyle(Color.primary.opacity(renderedOpacity).opacity(0.7))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            let literals = content.date.literals
            if let day = literals[dayLength],
               let date = literals[.date]
            {
                Text(day)
                    .foregroundStyle(dayColor)

                Text(date)
                    .foregroundStyle(.red)
            }
        }
        .font(.title3)
        .fontWeight(.bold)
        .textCase(.uppercase)
        .lineSpacing(0)
    }
}
