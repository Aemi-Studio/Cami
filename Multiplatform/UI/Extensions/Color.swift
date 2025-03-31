//
//  Color.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/03/25.
//

import SwiftUI

extension Color {
    func resolveBrighter(than threshold: Double = 0.5) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        let dataRegistered = uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return if dataRegistered, brightness < threshold {
            Color(hue: hue, saturation: saturation, brightness: 1 - brightness, opacity: alpha)
        } else {
            self
        }
    }

    func brighter(by amount: Double = 0) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        return if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            Color(
                hue: hue,
                saturation: saturation,
                brightness: amount > 0 ? brightness + amount * brightness : brightness - amount * brightness,
                opacity: alpha
            )
        } else {
            self
        }
    }
}

extension ShapeStyle where Self == TintShapeStyle {
    static var tint: some ShapeStyle {
        TintShapeStyle()
    }
}

extension View {
    func tinted(_ color: Color) -> some View {
        environment(\.tint, color)
            .tint(color)
    }
}

extension EnvironmentValues {
    @Entry var tint: Color = .accentColor
}
