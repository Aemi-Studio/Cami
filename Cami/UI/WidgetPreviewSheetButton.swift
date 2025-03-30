//
//  ReminderCreationButton 2.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import SwiftUI

struct WidgetPreviewSheetButton: View {

    @Environment(\.openModal) private var openModal

    @Environment(\.presentation)
    private var presentation

    func openWidgetPreviewSheet() {
        openModal?(.widgets)
    }

    var body: some View {
        Button {
            withAnimation {
                openWidgetPreviewSheet()
            }
        } label: {
            Image(systemName: "circle")
                .foregroundStyle(.clear)
                .overlay {
                    Label("Preview", systemImage: "widget.small")
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

extension View {
    func thinBorder(
        radius: CGFloat,
        color: any ShapeStyle = Color.primary.quaternary,
        lineWidth: CGFloat = 0.5
    ) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: radius)
                .fill(.clear)
                .stroke(AnyShapeStyle(color), lineWidth: lineWidth)
        }
    }
}
