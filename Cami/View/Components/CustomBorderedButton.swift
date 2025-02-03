//
//  CustomBorderedButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct CustomBorderedButton<Label, Title, Icon, Description>: View
where Label: View, Title: View, Icon: View, Description: View {
    private(set) var label: Label?
    private(set) var title: Title?
    private(set) var icon: Icon?
    private(set) var description: Description?

    private(set) var foregroundStyle: AnyShapeStyle?
    private(set) var backgroundStyle: AnyShapeStyle?
    private(set) var padding: Double = CustomDesign.borderedPadding
    private(set) var radius: Double = CustomDesign.borderedRadius
    private(set) var outline: Bool = false
    private(set) var noIcon: Bool = false
    private(set) var opacity: Double = 0.3
    private(set) var alignment: TextAlignment? = .leading
    private(set) var isPressed: Bool = false

    var halignment: HorizontalAlignment {
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
        CustomBordered(
            backgroundStyle: backgroundStyle,
            padding: padding,
            radius: radius,
            outline: outline,
            noIcon: noIcon,
            opacity: opacity,
            alignment: alignment,
            isPressed: isPressed
        ) {
            HStack(alignment: .center) {
                if let label {
                    label
                } else {
                    text
                    image
                }
            }
        }
    }

    private var foregroundColor: AnyShapeStyle {
        foregroundStyle != nil ? foregroundStyle! : AnyShapeStyle(.tint)
    }

    private var opaqueForegroundColor: AnyShapeStyle {
        foregroundStyle != nil ? foregroundStyle! : AnyShapeStyle(Color.primary)
    }

    private var backgroundColor: AnyShapeStyle {
        backgroundStyle != nil ? backgroundStyle! : AnyShapeStyle(.tint)
    }

    @ViewBuilder private var text: some View {
        VStack(alignment: halignment, spacing: 3) {
            Group {
                if opacity < 1.0 {
                    title
                        .foregroundStyle(foregroundColor)
                } else {
                    title
                        .foregroundStyle(opaqueForegroundColor)
                }

                if let description {
                    if opacity < 1 {
                        description
                            .font(.caption)
                            .foregroundStyle(foregroundColor.opacity(0.8))
                    } else {
                        description
                            .font(.caption)
                            .foregroundStyle(opaqueForegroundColor.opacity(0.8))
                    }
                }
            }
            .accessibilityHidden(true)
            .multilineTextAlignment(alignment ?? .leading)
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: halignment, vertical: .center))
    }

    @ViewBuilder private var image: some View {
        if noIcon != true, let icon {
            Spacer()
            VStack(alignment: .center) {
                if opacity < 1 {
                    icon
                        .foregroundStyle(foregroundColor)
                        .accessibilityHidden(true)
                } else {
                    icon
                        .foregroundStyle(opaqueForegroundColor)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

extension CustomBorderedButton {
    init(
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description? = { nil }
    ) where Title == EmptyView, Icon == EmptyView {
        self.label = label()
        self.description = description()
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false,
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder icon: @escaping () -> Icon,
        @ViewBuilder description: @escaping () -> Description?
    ) where Label == AnyView {
        self.title = title()
        self.icon = icon()
        self.description = description()
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
        _ title: String,
        description: String? = nil,
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false
    ) where Label == EmptyView, Title == Text, Icon == Image, Description == AnyView {
        self.title = Text(title)
        self.description = description != nil ? AnyView(Text(description!)) : AnyView(EmptyView())
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
        _ title: String,
        systemImage: String,
        description: String? = nil,
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false
    ) where Label == EmptyView, Title == Text, Icon == Image, Description == AnyView {
        self.title = Text(title)
        icon = Image(systemName: systemImage)
        self.description = description != nil ? AnyView(Text(description!)) : AnyView(EmptyView())
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
        _ title: String,
        image: String,
        description: String? = nil,
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false
    ) where Label == EmptyView, Title == Text, Icon == Image, Description == AnyView {
        self.title = Text(title)
        icon = Image(image)
        self.description = description != nil ? AnyView(Text(description!)) : AnyView(EmptyView())
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
        title: Title,
        icon: Icon,
        description: String? = nil,
        foregroundStyle: (any ShapeStyle)? = nil,
        backgroundStyle: (any ShapeStyle)? = nil,
        padding: Double = CustomDesign.borderedPadding,
        radius: Double = CustomDesign.borderedRadius,
        outline: Bool = false,
        noIcon: Bool = false,
        opacity: Double = 0.3,
        alignment: TextAlignment? = .leading,
        isPressed: Bool = false
    ) where Label == EmptyView, Description == AnyView {
        self.title = title
        self.icon = icon
        self.description = description != nil ? AnyView(Text(description!)) : AnyView(EmptyView())
        self.foregroundStyle = foregroundStyle != nil ? AnyShapeStyle(foregroundStyle!) : nil
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
