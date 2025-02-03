//
//  ScrollableHome.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI
import AemiUtilities

@MainActor
struct ScrollableHome: View {

    @Environment(\.path) private var path
    @Environment(\.presentation) private var presentation

    var body: some View {
        if let path, let controller = path.controller {
            @Bindable var path = path
            @Bindable var controller = controller
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(path.path) { page in
                            page()
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .task { controller.attach(proxy) }
                .scrollPosition(id: $controller.scrollPosition, anchor: .center)
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .defaultScrollAnchor(.leading)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            }
        }
    }
}

extension View {

    func thinBorder(
        radius: CGFloat,
        color: any ShapeStyle = Color.primary.quaternary,
        lineWidth: CGFloat = 0.5
    ) -> some View {
        self
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .fill(.clear)
                    .stroke(AnyShapeStyle(color), lineWidth: lineWidth)
            }
    }

}

struct ReminderCreationButton: View {

    @Environment(\.presentation) private var presentation

    func openReminderCreationSheet() {
        presentation?.isReminderCreationSheetPresented = true
    }

    var body: some View {
        Button {
            withAnimation {
                openReminderCreationSheet()
            }
        } label: {
            Image(systemName: "circle")
                .foregroundStyle(.clear)
                .overlay {
                    Label("Create a reminder", systemImage: "plus")
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
