//
//  ScrollableHome.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import AemiUtilities
import SwiftUI

@MainActor
struct ScrollableHome: View {
    @Environment(\.path) private var path
    @Environment(\.presentation) private var presentation

    var body: some View {
        if let path, let controller = path.controller {
            @Bindable var path = path
            @Bindable var controller = controller
            //            ScrollViewReader { proxy in
            //                ScrollView(.horizontal) {
            //                    LazyHStack {
            if let page = path.path.last {
                page()
            }
            //                    }
            //                    .scrollTargetLayout()
            //                }
            //                .task { controller.attach(proxy) }
            //                .scrollPosition(id: $controller.scrollPosition, anchor: .center)
            //                .scrollIndicators(.hidden)
            //                .scrollBounceBehavior(.automatic)
            //                .defaultScrollAnchor(.leading)
            //                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
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
