//
//  BlurryEdgeViewModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/04/25.
//

import SwiftUI

struct BlurryEdgeViewModifier: ViewModifier {

    enum Edge {
        case top
        case bottom
    }

    enum Position {
        case below
        case above
    }

    let edge: Edge
    let position: Position
    private(set) var alignment: Alignment = .top
    let height: CGFloat?
    let radius: CGFloat

    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            withPosition {
                content
            }
        }
    }

    @ViewBuilder private func withPosition(@ViewBuilder content: () -> some View) -> some View {
        if position == .above {
            content()
            variableBlurView
        } else {
            variableBlurView
            content()
        }
    }

    private var variableBlurView: some View {
        Color.clear.overlay(alignment: edge == .top ? .top : .bottom) {
            VariableBlurView(
                maxBlurRadius: radius,
                direction: edge == .top ? .blurredTopClearBottom : .blurredBottomClearTop
            )
            .frame(height: height)
        }
    }
}

extension View {
    func blurryEdge(
        edge: BlurryEdgeViewModifier.Edge,
        position: BlurryEdgeViewModifier.Position = .below,
        alignment: Alignment = .top,
        height: CGFloat?,
        radius: CGFloat
    ) -> some View {
        modifier(BlurryEdgeViewModifier(
            edge: edge,
            position: position,
            alignment: alignment,
            height: height,
            radius: radius
        ))
    }
}
