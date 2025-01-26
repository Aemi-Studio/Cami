//
//  ScrollableHome.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

@MainActor
struct ScrollableHome: View {

    @State var context: ScrollableHomeContext

    init(_ ids: [Page]) {
        context = .init(ids)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(context.pages) { page in
                        page()
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .task { context.attach(proxy) }
            .scrollPosition(id: $context.scrollPosition, anchor: .center)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(.leading)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .blurredEdges()
            .overlay(alignment: .bottom) {
                Color.clear.safeAreaInset(edge: .bottom) {
                    BottomBar(context: context)
                }
            }
        }
    }
}

struct BottomBar: View {

    let context: ScrollableHomeContext

    var body: some View {
        VStack(alignment: .center) {
            //            HStack(spacing: 4) {
            //                ForEach(context.pages) { page in
            //                    Capsule()
            //                        .frame(width: context.scrollPosition == page ? 32 : 8, height: 8)
            //                }
            //            }
            HStack(spacing: 8) {
                ForEach(context.pages) { page in
                    Button {
                        withAnimation {
                            context.scrollPosition = page
                        }
                    } label: {
                        Image(systemName: "circle")
                            .foregroundStyle(.clear)
                            .overlay {
                                Label(page.localizedDescription, systemImage: page.icon)
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

                ReminderCreationButton()

            }
            .padding(8)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 12))
            .thinBorder(radius: 12)
        }
        //        .padding(.bottom)
        .animation(.spring, value: context.scrollPosition)
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
