//
//  RoundedClipShape.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import SwiftUI
import WidgetKit

struct Rounded: ViewModifier {

    @Environment(\.widgetFamily) var _widgetFamily: WidgetFamily

    private func getCorrespondingRadii(
        _ widgetFamily: WidgetFamily,
        radii: [WidgetFamilySet: RectangleCornerRadii]
    ) -> RectangleCornerRadii {
        for (widgetSet,_radii) in radii {
            if widgetSet.contains(WidgetFamilySet.convert(widgetFamily)) {
                return _radii
            }
        }
        return RectangleCornerRadii()
    }

    var radii: [WidgetFamilySet: RectangleCornerRadii]
    var widgetFamily: WidgetFamily? = nil

    func body(content: Content) -> some View {
        content
            .clipShape(
                UnevenRoundedRectangle(cornerRadii: getCorrespondingRadii(
                    widgetFamily ?? _widgetFamily,
                    radii: radii
                ))
            )
    }
}

extension View {
    func rounded(
        _ radii: [WidgetFamilySet: RectangleCornerRadii],
        widgetFamily: WidgetFamily? = nil
    ) -> some View {
        modifier(Rounded(
            radii: radii,
            widgetFamily: widgetFamily
        ))
    }

    func rounded(
        _ radii: [WidgetFamilySet: CGFloat],
        widgetFamily: WidgetFamily? = nil
    ) -> some View {
        modifier(Rounded(
            radii: radii.mapValues { value in RectangleCornerRadii(value) },
            widgetFamily: widgetFamily
        ))
    }
}


