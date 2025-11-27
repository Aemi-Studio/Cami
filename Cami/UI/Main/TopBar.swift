//
//  TopBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import AemiSDR
import SwiftUI

struct TopBar<LeadingContent: View, TrailingContent: View>: View {
    private let scrollOffset: CGFloat
    private let leadingContent: () -> LeadingContent
    private let trailingContent: () -> TrailingContent
    
    @State private var topSafeAreaInset = CGFloat.zero
    @State private var viewHeight = CGFloat.zero
    
    // Scaled metrics for size classes
    @ScaledMetric private var maxBarHeight: CGFloat = 48
    @ScaledMetric private var minBarHeight: CGFloat = 32
    @ScaledMetric private var title3FontSize: CGFloat = 20
    @ScaledMetric private var largeTitleFontSize: CGFloat = 34
    
    // Scroll threshold: distance to complete the transition
    private let scrollThreshold: CGFloat = 80
    
    private let spacingRange: (CGFloat, CGFloat) = (4.0, 0.0)
    private let paddingRange: (CGFloat, CGFloat) = (-4.0, -8.0)
    
    init(
        scrollOffset: CGFloat,
        @ViewBuilder leading: @escaping () -> LeadingContent,
        @ViewBuilder trailing: @escaping () -> TrailingContent = EmptyView.init
    ) {
        self.scrollOffset = abs(min(scrollOffset, 0))
        self.leadingContent = leading
        self.trailingContent = trailing
    }
    
    // MARK: - Computed Properties
    
    /// Normalized scroll progress: 0 (top) → 1 (threshold reached)
    private var scrollProgress: CGFloat {
        min(scrollOffset / scrollThreshold, 1.0)
    }
    
    /// Dynamic HStack height that shrinks with scroll
    private var dynamicHeight: CGFloat {
        maxBarHeight - (scrollProgress * (maxBarHeight - minBarHeight))
    }
    
    private var heightRange: (CGFloat, CGFloat) {
        (maxBarHeight, minBarHeight)
    }
    
    private var fontSizeRange: (CGFloat, CGFloat) {
        (largeTitleFontSize, title3FontSize)
    }
    
    /// Dynamic opacity for subtle fade effect during scroll
    private var contentOpacity: CGFloat {
        1.0 - (scrollProgress * 0.1)
    }

    /// Dynamic blur for depth effect
    private var backgroundBlur: CGFloat {
        scrollProgress * 0.5
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            HStack(alignment: .center) {
                leadingContent()
                    .font(.system(size: dynamicHeight.mapped(from: heightRange, to: fontSizeRange)))
                    .opacity(contentOpacity)
                    .scaleEffect(1.0 - (scrollProgress * 0.02), anchor: .leading)

                Spacer()

                HStack(spacing: dynamicHeight.mapped(from: heightRange, to: spacingRange)) {
                    trailingContent()
                }
                .buttonStyle(CircularGlassButtonStyle(dynamicHeight))
                .padding(.trailing, dynamicHeight.mapped(from: heightRange, to: paddingRange))
                .scaleEffect(1.0 - (scrollProgress * 0.05))
            }
            .padding(.horizontal)
            .frame(height: dynamicHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: maxBarHeight)
        .padding(.bottom)
        .dynamicTypeSize(...(.large))
        .track(height: $viewHeight)
        .track(safeAreaInsets: $topSafeAreaInset, edge: .top)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scrollProgress)
        .animation(.easeInOut, value: viewHeight)
    }
}
