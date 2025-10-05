//
//  NavigationPageLink.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import AemiSDR
import SwiftUI

extension View {
    func navigationStackStyleReset(blurOffset: CGFloat) -> some View {
        self
            .modifier(ResetToolbarBackground(blurOffset: blurOffset))
            .containerNavigationBackground()
            .transition(.blurReplace)
    }
}

struct ResetToolbarBackground: ViewModifier {
    @State private var topSafeAreaInset = CGFloat.zero

    @ViewBuilder
    private func hideToolbar(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 18.0, *) {
            content().toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        } else {
            content().toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func applyMaskAndBlur(@ViewBuilder content: () -> some View) -> some View {
        content()
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
            .mask(alignment: .top) { maskContent }
            .overlay(alignment: .top) { blurContent }
            .track(safeAreaInsets: $topSafeAreaInset, edge: .top)
    }

    private var maskContent: some View {
        VStack(spacing: 0) {
            GradientMask(direction: .up)
                .frame(height: topSafeAreaInset - (80 - blurOffset))
            Color.black
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var blurContent: some View {
        VariableBlurView(maxBlurRadius: 5)
            .frame(height: topSafeAreaInset - (80 - blurOffset))
            .ignoresSafeArea(edges: .top)
    }
    
    let blurOffset: CGFloat

    func body(content: Content) -> some View {
        hideToolbar {
            applyMaskAndBlur {
                content
            }
        }
    }
}

extension View {
    @ViewBuilder
    func containerNavigationBackground() -> some View {
        if #available(iOS 18.0, *) {
            containerBackground(.clear, for: .navigation)
        } else {
            background()
        }
    }
}
