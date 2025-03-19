//
//  ViewTopBar.swift
//  Realm
//
//  Created by Guillaume Coquard on 16/02/25.
//

import SwiftUI

struct ViewTopBar: View {

    @Environment(\.hierarchy) private var hierarchy
    @Environment(\.presentation) private var presentation
    @Environment(\.viewKind) private var viewKind

    @Namespace private var matchedTitle

    private let columns: [GridItem] = [
        .init(.flexible(), alignment: .leading),
        .init(.flexible(), alignment: .center),
        .init(.flexible(), alignment: .trailing)
    ]

    private var context: ViewContext? {
        hierarchy?.context
    }

    var body: some View {
        @Bindable var presentation = presentation
        VStack(alignment: .center) {
            horizontalMenu
            ViewSearchBar()
        }
        .if(viewKind != .sheet) {
            $0.safeAreaPadding(.top, EdgeInsets.safeAreaInsets.top)
        } else: {
            $0.safeAreaPadding(.top)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            VariableBlurView(maxBlurRadius: 20, direction: .blurredTopClearBottom)
        }
        .fixedSize(horizontal: false, vertical: true)
        .update($presentation.topBarSize)
        .animation(.default, value: context?.title)
        .animation(.default, value: context?.parent?.title)
    }

    @ViewBuilder
    private var horizontalMenu: some View {
        if let context {
            LazyVGrid(columns: columns) {
                Color.clear.overlay(alignment: .leading) {
                    backButton
                }

                Text(context.title)
                    .matchedGeometryEffect(
                        id: context.id,
                        in: matchedTitle
                    )
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .fixedSize()
                    .transition(.blurReplace)

                Color.clear.overlay(alignment: .trailing) {
                    AnyView(context.buttons())
                }
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
    }

    @ScaledMetric
    private var backButtonChevronSize: CGFloat = 22

    @ViewBuilder
    private var backButton: some View {
        if let context, let parent = context.parent {
            Button {
                hierarchy?.move(to: parent)
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: backButtonChevronSize, weight: .medium))
                        .offset(x: -4)
                    Text(parent.title)
                        .matchedGeometryEffect(
                            id: parent.id,
                            in: matchedTitle
                        )
                        .lineLimit(1)
                        .fixedSize()
                }
            }
        } else {
            Spacer()
        }
    }
}
