//
//  CamiWidgetHeader.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 15/11/23.
//

import EventKit
import SwiftUI
import WidgetKit

struct CamiWidgetHeader: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.widgetRenderingMode)
    private var renderingMode

    @Environment(\.widgetContent)
    private var content

    private var backgroundColor: some ShapeStyle {
        if colorScheme == .dark {
            Color.black.opacity(0.2)
        } else {
            Color.white.opacity(0.2)
        }
    }

    private var paddingInsets: EdgeInsets {
        if colorScheme == .dark {
            EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 5)
        } else {
            EdgeInsets(top: 1, leading: 5, bottom: 1, trailing: 2)
        }
    }

    private var renderedOpacity: Double {
        switch renderingMode {
        case .accented, .vibrant: 0.05
        default: 0.2
        }
    }

    private var headerDateAccessibilityLabel: String {
        "Today's date is " + content.date.formatter {
            $0.dateStyle = .full
            $0.timeStyle = .none
            $0.formattingContext = .standalone
        }
    }

    @AppStorage(SettingsKeys.openInCami)
    private var openInPlace: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.openInCami)

    var body: some View {
        HStack(spacing: 0) {
            Link(destination: DataContext.shared.destination(for: content.date, inPlace: openInPlace)) {
                CamiWidgetHeaderDate()
                    .accessibilityLabel(String(localized: "\(headerDateAccessibilityLabel)"))
            }

            Spacer()

            HStack(spacing: 5) {
                CamiWidgetCreateEventButton()

                CamiWidgetHeaderCornerComplication()
            }
        }
        .padding(paddingInsets)
        .background(backgroundColor)
        .rounded([.all: .init(top: 16, bottom: 8)])
        .lineLimit(1)
        .fontDesign(.rounded)
    }
}

struct CamiWidgetCreateEventButton: View {
    @Environment(\.widgetFamily)
    private var environmentWidgetFamily

    @Environment(\.customWidgetFamily)
    private var customWidgetFamily

    private var family: WidgetFamily {
        customWidgetFamily?.rawValue ?? environmentWidgetFamily
    }

    var body: some View {
        Link(destination: DataContext.shared.creationURL) {
            Label(String(localized: "Create event or reminder"), systemImage: "plus")
                .labelStyle(.iconOnly)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary.secondary)
        }
        .padding(family.isSmall ? 3 : 4.75)
        .background(Color.primary.quinary.opacity(0.3))
        .clipShape(.rect(cornerRadius: 4))
    }
}
