//
//  CustomBordered.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct CustomBordered<Content>: View
where Content: View {
    private(set) var content: Content?

    private(set) var backgroundStyle: AnyShapeStyle?
    private(set) var padding: Double = CustomDesign.borderedPadding
    private(set) var radius: Double = CustomDesign.borderedRadius
    private(set) var outline: Bool = false
    private(set) var noIcon: Bool = false
    private(set) var opacity: Double = 0.3
    private(set) var alignment: TextAlignment? = .leading
    private(set) var isPressed: Bool = false

    private var backgroundColor: AnyShapeStyle {
        backgroundStyle != nil ? backgroundStyle! : AnyShapeStyle(.tint)
    }

    private var halignment: HorizontalAlignment {
        return switch alignment {
        case .center:
            .center
        case .trailing:
            .trailing
        default:
            .leading
        }
    }

    var body: some View {
        withPressedStyle {
            withButtonStyle {
                content
            }
        }
    }

    @ViewBuilder private func withButtonStyle(@ViewBuilder content: @escaping () -> some View) -> some View {
        HStack {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
        .if(opacity < 1) {
            $0.background(VisualEffect(blurRadius: 30))
        }
        .background(backgroundColor.opacity(opacity))
        .clipShape(.rect(cornerRadius: radius))
        .overlay {
            if outline == true {
                RoundedRectangle(cornerRadius: radius)
                    .fill(.clear)
                    .stroke(
                        backgroundColor.secondary.tertiary,
                        lineWidth: CustomDesign.borderedStrokeWidth
                    )
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder private func withPressedStyle(@ViewBuilder content: @escaping () -> some View) -> some View {
        if isPressed {
            content()
                .opacity(0.5)
        } else {
            content()
        }
    }
}

extension CustomBordered {
    init(
        _ content: () -> Content,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false
    ) {
        self.content = content()
        self.backgroundStyle = backgroundStyle != nil ? AnyShapeStyle(backgroundStyle!) : nil
        self.padding = padding
        self.radius = radius
        self.outline = outline
        self.noIcon = noIcon
        self.opacity = opacity
        self.alignment = alignment
        self.isPressed = isPressed
    }

    init(
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self.backgroundStyle = backgroundStyle != nil ? AnyShapeStyle(backgroundStyle!) : nil
        self.padding = padding
        self.radius = radius
        self.outline = outline
        self.noIcon = noIcon
        self.opacity = opacity
        self.alignment = alignment
        self.isPressed = isPressed
    }
}
