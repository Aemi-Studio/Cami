//
//  CustomBorderedButtonStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct CustomBorderedButtonStyle: ButtonStyle {

    private(set) var layout: Bool = true
    private(set) var description: String?
    private(set) var foregroundStyle: AnyShapeStyle?
    private(set) var backgroundStyle: AnyShapeStyle?
    private(set) var padding: Double = CustomDesign.borderedPadding
    private(set) var radius: Double = CustomDesign.borderedRadius
    private(set) var outline: Bool = false
    private(set) var opacity: Double = 0.1
    private(set) var noIcon: Bool = false
    private(set) var alignment: TextAlignment? = .leading

    @ViewBuilder
    private func makeLayout(configuration: Configuration) -> some View {
        if layout {
            CustomBorderedButton(
                foregroundStyle: foregroundStyle,
                backgroundStyle: backgroundStyle,
                padding: padding,
                radius: radius,
                outline: outline,
                noIcon: noIcon,
                opacity: opacity,
                alignment: alignment,
                isPressed: configuration.isPressed,
                title: { configuration.label.labelStyle(.titleOnly) },
                icon: { configuration.label.labelStyle(.iconOnly) },
                description: { description != nil ? Text(description!) : nil }
            )
        } else {
            CustomBorderedButton(
                foregroundStyle: foregroundStyle,
                backgroundStyle: backgroundStyle,
                padding: padding,
                radius: radius,
                outline: outline,
                noIcon: noIcon,
                opacity: opacity,
                alignment: alignment,
                isPressed: configuration.isPressed
            ) {
                configuration.label
            } description: {
                description != nil ? Text(description!) : nil
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        makeLayout(configuration: configuration)
    }
}

extension ButtonStyle where Self == CustomBorderedButtonStyle {

    static var primary: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.primary),
            backgroundStyle: AnyShapeStyle(Color.secondary)
        )
    }

    static var primaryWithOutline: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.primary),
            backgroundStyle: AnyShapeStyle(Color.primary.secondary),
            outline: true
        )
    }

    static var secondary: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.primary.secondary),
            backgroundStyle: AnyShapeStyle(Color.primary.tertiary)
        )
    }

    static var secondaryWithOutline: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.primary.secondary),
            backgroundStyle: AnyShapeStyle(Color.primary.tertiary),
            outline: true
        )
    }

    static var accent: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle()
    }

    static var accentWithOutline: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(outline: true)
    }

    static var accentOverSecondary: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.accentColor),
            backgroundStyle: AnyShapeStyle(Color.primary.secondary)
        )
    }

    static var accentOverSecondaryWithOutline: CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            foregroundStyle: AnyShapeStyle(Color.accentColor),
            backgroundStyle: AnyShapeStyle(Color.primary.secondary),
            outline: true
        )
    }

    static func customBorderedButton(
        layout: Bool = true,
        description: String? = nil,
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        opacity: Double = 0.1,
        noIcon: Bool = false,
        alignment: TextAlignment? = .leading
    ) -> CustomBorderedButtonStyle {
        CustomBorderedButtonStyle(
            layout: layout,
            description: description,
            foregroundStyle: foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil,
            backgroundStyle: backgroundStyle != nil ? AnyShapeStyle(backgroundStyle!) : nil,
            padding: padding,
            radius: radius,
            outline: outline,
            opacity: opacity,
            noIcon: noIcon,
            alignment: alignment
        )
    }
}
