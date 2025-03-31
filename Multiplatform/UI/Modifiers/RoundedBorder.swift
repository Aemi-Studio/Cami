//
//  RoundedBorder.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct RoundedBorder: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.tint) private var tint

    private let cornerRadius: CGFloat = 4.0

    private(set) var bordered: Bool = false
    private(set) var radii = RectangleCornerRadiiFilter()

    private var strokeWidth: Double {
        bordered ? 2 : 0
    }

    private var foregroundStyle: some ShapeStyle {
        tint
            .resolveBrighter(than: colorScheme == .dark ? 0.3 : 0)
            .brighter(by: colorScheme == .dark ? 0.2 : -0.2)
    }

    private var backgroundStyle: some ShapeStyle {
        tint.quinary.opacity(colorScheme == .light ? 0.4 : 0.8)
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundStyle)
            .fontDesign(.rounded)
            .if(colorScheme == .light) { view in
                view
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 2)
            .padding([radii.all ? .horizontal : .trailing], 4)
            .if(bordered) { view in
                view
                    .overlay {
                        UnevenRoundedRectangle(cornerRadii: radii.apply(to: CGFloat(cornerRadius)))
                            .fill(.clear)
                            .stroke(tint.quaternary, lineWidth: strokeWidth)
                    }
            } else: { view in
                view
                    .background(backgroundStyle)
                    .clipShape(.rect(cornerRadii: radii.apply(to: CGFloat(cornerRadius))))
            }
    }
}

extension View {
    func roundedBorder(
        bordered: Bool = false,
        radii: RectangleCornerRadiiFilter = .init()
    ) -> some View {
        modifier(RoundedBorder(
            bordered: bordered,
            radii: radii
        ))
    }
}
