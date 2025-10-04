//
//  ScrollOffsetReader.swift
//  Cami
//
//  Created by Guillaume Coquard on 04.10.25.
//

import SwiftUI

/// A lightweight wrapper around `ScrollView` that reports its current scroll offset via a binding.
///
/// `ScrollOffsetReader` embeds your content in a `ScrollView` and continuously updates the
/// provided `Binding<CGFloat>` with the current content offset along the selected axis.
///
/// On iOS 26 and later, it uses `onScrollGeometryChange` for precise, efficient tracking.
/// On earlier systems, it falls back to `onGeometryChange`.
///
/// Usage:
/// ```swift
/// @State private var offset: CGFloat = 0
///
/// ScrollOffsetReader($offset) {
///     // Scrollable content
/// }
/// ```
struct ScrollOffsetReader<Content>: View where Content: View {
    // MARK: - Configuration
    
    /// The scrollable axis (or axes) to track.
    private let axis: Axis.Set
    /// The scrollable content.
    private let content: Content
    /// Whether to show the system scroll indicators.
    private let showsIndicators: Bool
    
    /// The current scroll offset along `axis`.
    /// Updated continuously as the user scrolls.
    @Binding private var offset: CGFloat

    // MARK: - Initializers
    
    /// Creates a scroll offset reader with a view builder.
    /// - Parameters:
    ///   - offset: A binding that receives the current scroll offset along the specified axis.
    ///   - axis: The scrollable axes. Defaults to `.vertical`.
    ///   - showsIndicators: Whether the scroll view shows scroll indicators. Defaults to `true`.
    ///   - content: A view builder that produces the scrollable content.
    init(
        _ offset: Binding<CGFloat>,
        axis: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.axis = axis
        self.content = content()
        self.showsIndicators = showsIndicators
        
        self._offset = offset
    }
    
    /// Creates a scroll offset reader with an explicit content view.
    /// - Parameters:
    ///   - offset: A binding that receives the current scroll offset along the specified axis.
    ///   - axis: The scrollable axes. Defaults to `.vertical`.
    ///   - showsIndicators: Whether the scroll view shows scroll indicators. Defaults to `true`.
    ///   - content: The scrollable content view.
    init(
        _ offset: Binding<CGFloat>,
        axis: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        content: Content
    ) {
        self.axis = axis
        self.content = content
        self.showsIndicators = showsIndicators
        
        self._offset = offset
    }

    // MARK: - Body
    /// Wraps the content in a `ScrollView` and tracks its offset.
    var body: some View {
        ScrollView(axis, showsIndicators: showsIndicators) {
            computeScrollOffset(content)
        }
    }
    
    // MARK: - Offset computation
    /// Computes and propagates the current scroll offset for the given content.
    @ViewBuilder
    private func computeScrollOffset<C>(_ content: C) -> some View where C: View {
        content
            .onGeometryChange(
                for: CGFloat.self,
                of: {
                    offset(forAxis: axis, $0.frame(in: .scrollView).origin)
                },
                action: {
                    if offset != $0 {
                        offset = $0
                    }
                }
            )
    }
    
    /// Extracts the relevant component from a point for the given axis.
    /// - Parameters:
    ///   - axis: The axis whose offset should be returned.
    ///   - point: The measured content offset or origin.
    /// - Returns: `point.x` when tracking horizontally, otherwise `point.y`.
    private func offset(forAxis axis: Axis.Set, _ point: CGPoint) -> CGFloat {
        switch axis {
            case .horizontal: point.x
            case .vertical: point.y
            default: point.y
        }
    }
}
