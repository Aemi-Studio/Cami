//
//  SummaryCountView.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct SummaryCountView: View {
    @Environment(AppNavigation.self) private var navigation: AppNavigation?

    private(set) var kind: CalendarItemKind
    private(set) var count: Int
    @Binding private(set) var binding: Bool

    @State private var isPressed = false

    var body: some View {
        toggle
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
            .contextMenu { contextMenu }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
            .sensoryFeedback(.selection, trigger: binding)
    }

    private var toggle: some View {
        Toggle(isOn: $binding) {
            Text(count == 1 ? kind.description : kind.pluralDescription)
        }
        .toggleStyle(.unifiedCapsule(count: count))
    }

    private var contextMenu: some View {
        Button(kind.listPluralDescription, systemImage: kind.listSystemImage) {
            navigation?.navigate(to: .calendarSelection(kind: kind))
        }
    }
}
