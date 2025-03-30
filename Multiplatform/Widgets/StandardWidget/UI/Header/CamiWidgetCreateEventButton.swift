//
//  CamiWidgetCreateEventButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI
import WidgetKit

struct CamiWidgetCreateEventButton: View {
    @Environment(\.widgetFamily)
    private var environmentWidgetFamily

    @Environment(\.customWidgetFamily)
    private var customWidgetFamily

    private var family: WidgetFamily {
        customWidgetFamily?.rawValue ?? environmentWidgetFamily
    }
    
    private(set) var customRadius: Bool

    var body: some View {
        Link(destination: DataContext.shared.creationURL) {
            Label(String(localized: "Create event or reminder"), systemImage: "plus")
                .labelStyle(.iconOnly)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary.secondary)
        }
        .padding(family.isSmall ? 3 : 4.75)
        .background(Color.primary.quinary.opacity(0.3))
        .clipShape(
            customRadius
            ? .rect(cornerRadii: .init(topLeading: 4, bottomLeading: 4, bottomTrailing: 4, topTrailing: 12))
            : .rect(cornerRadii: .init(4))
        )
    }
}
