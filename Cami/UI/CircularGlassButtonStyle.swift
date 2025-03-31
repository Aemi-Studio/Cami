//
//  CircularGlassButtonStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import SwiftUI

struct CircularGlassButtonStyle: ButtonStyle {
    @ScaledMetric
    private var ratio = 1.0
    private var fontSize: CGFloat { min(max(size * ratio * 0.333, size * 0.5), size * 0.75) }
    private let defaultSize: CGFloat = 48
    private let maxVisualSize: CGFloat = 40
    private let size: CGFloat

    init(_ size: CGFloat = 48) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        GlassStyle(.circle)
            .overlay {
                configuration.label
                    .labelStyle(.iconOnly)
                    .font(.system(size: fontSize))
                    .fontWeight(.bold)
            }
            .padding(max(0, maxVisualSize - size) / 2)
            .padding((defaultSize - maxVisualSize) / 2)
            .frame(width: defaultSize, height: defaultSize)
            .contentShape(.circle)
            .animation(.interactiveSpring(duration: 0.25), value: size)
    }
}

struct CapsuleGlassButtonStyle: ButtonStyle {
    private(set) var color: Color
    private(set) var intensity: CGFloat = 0.1
    private(set) var radius: CGFloat = 10
    private(set) var labelStyle: any LabelStyle = .titleAndIcon
    private(set) var padding: EdgeInsets = .init()

    func makeBody(configuration: Configuration) -> some View {
        GlassContentStyle(
            .capsule,
            color: color,
            intensity: intensity,
            radius: radius
        ) {
            configuration.label
                .labelStyle(.titleOnly)
                .padding(padding)
        }
    }
}

struct GlassContentStyle<Content: View, Base: Shape>: View {
    private let shape: Base
    private let color: Color
    private let lineWidth: CGFloat
    private let intensity: CGFloat
    private let radius: CGFloat
    private let content: () -> Content

    init(
        _ shape: Base = Rectangle(),
        color: Color = Color.primary,
        lineWidth: CGFloat = 1,
        intensity: CGFloat = 0.1,
        radius: CGFloat = 10,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.shape = shape
        self.color = color
        self.lineWidth = lineWidth
        self.intensity = intensity
        self.radius = radius
        self.content = content
    }

    var body: some View {
        content()
            .background {
                applyBlur {
                    applyStroke {
                        shape.fill(.clear)
                    }
                }
            }
            .clipShape(shape)
    }

    @ViewBuilder private func applyStroke(@ViewBuilder content: () -> some ShapeView) -> some View {
        if lineWidth > 0 {
            content()
                .stroke(color.quaternary, lineWidth: lineWidth)
        } else {
            content()
        }
    }

    @ViewBuilder private func applyBlur(@ViewBuilder content: () -> some View) -> some View {
        if intensity > 0 || radius > 0 {
            content()
                .background(VisualEffect(colorTint: color, colorTintAlpha: intensity, blurRadius: radius))
        } else {
            content()
        }
    }
}

struct GlassStyle<Base: Shape>: View {
    private let shape: Base
    private let color: Color
    private let lineWidth: CGFloat
    private let intensity: CGFloat
    private let radius: CGFloat
    init(
        _ shape: Base = Rectangle(),
        color: Color = Color.primary,
        lineWidth: CGFloat = 1,
        intensity: CGFloat = 0.1,
        radius: CGFloat = 10
    ) {
        self.shape = shape
        self.color = color
        self.lineWidth = lineWidth
        self.intensity = intensity
        self.radius = radius
    }

    var body: some View {
        applyBlur {
            applyStroke {
                shape
                    .fill(.clear)
            }
        }
        .clipShape(shape)
    }

    @ViewBuilder private func applyStroke(@ViewBuilder content: () -> some ShapeView) -> some View {
        if lineWidth > 0 {
            content()
                .stroke(color.quaternary, lineWidth: lineWidth)
        } else {
            content()
        }
    }

    @ViewBuilder private func applyBlur(@ViewBuilder content: () -> some View) -> some View {
        if intensity > 0 || radius > 0 {
            content()
                .background(VisualEffect(colorTint: color, colorTintAlpha: intensity, blurRadius: radius))
        } else {
            content()
        }
    }
}
