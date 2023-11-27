//
//  Pad.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import SwiftUI
import WidgetKit

struct Pad: ViewModifier {

    @Environment(\.widgetFamily)
    var envWidgetFamily: WidgetFamily

    private func getCorrespondingInsets(
        _ widgetFamily: WidgetFamily,
        insets: [WidgetFamilySet: EdgeInsets]
    ) -> EdgeInsets {
        for (widgetSet, inset) in insets {
            if widgetSet.contains(WidgetFamilySet.convert(widgetFamily)) {
                return inset
            }
        }
        return EdgeInsets()
    }

    private func getCorrespondingEdgeSet(
        _ widgetFamily: WidgetFamily,
        edgeSets: [WidgetFamilySet: (Edge.Set, CGFloat)]
    ) -> (Edge.Set, CGFloat) {
        for (widgetSet, edgeSet) in edgeSets {
            if widgetSet.contains(WidgetFamilySet.convert(widgetFamily)) {
                return edgeSet
            }
        }
        return (Edge.Set(), 0)
    }

    private func getCorrespondingPadding(
        _ widgetFamily: WidgetFamily,
        paddings: [WidgetFamilySet: CGFloat]
    ) -> CGFloat {
        for (widgetSet, padding) in paddings {
            if widgetSet.contains(WidgetFamilySet.convert(widgetFamily)) {
                return padding
            }
        }
        return 0
    }

    var insets: [WidgetFamilySet: EdgeInsets]?
    var edgeSets: [WidgetFamilySet: (Edge.Set, CGFloat)]?
    var paddings: [WidgetFamilySet: CGFloat]?
    var widgetFamily: WidgetFamily?

    init(
        insets: [WidgetFamilySet: EdgeInsets],
        widgetFamily: WidgetFamily? = nil
    ) {
        self.insets = insets
        self.widgetFamily = widgetFamily
    }

    init(
        edgeSets: [WidgetFamilySet: (Edge.Set, CGFloat)],
        widgetFamily: WidgetFamily? = nil
    ) {
        self.edgeSets = edgeSets
        self.widgetFamily = widgetFamily
    }

    init(
        paddings: [WidgetFamilySet: CGFloat],
        widgetFamily: WidgetFamily? = nil
    ) {
        self.paddings = paddings
        self.widgetFamily = widgetFamily
    }

    func body(content: Content) -> some View {

        if insets != nil {
            content
                .padding(
                    getCorrespondingInsets(
                        widgetFamily ?? envWidgetFamily,
                        insets: insets!
                    )
                )
        } else if edgeSets != nil {
            let padding: (Edge.Set, CGFloat) = getCorrespondingEdgeSet(
                widgetFamily ?? envWidgetFamily,
                edgeSets: edgeSets!
            )
            content
                .padding(padding.0, padding.1)
        } else if paddings != nil {
            content
                .padding(
                    getCorrespondingPadding(
                        widgetFamily ?? envWidgetFamily,
                        paddings: paddings!
                    )
                )
        }

    }
}

extension View {
    func pad(
        _ insets: [WidgetFamilySet: EdgeInsets],
        widgetFamily: WidgetFamily? = nil
    ) -> some View {
        modifier(Pad(
            insets: insets,
            widgetFamily: widgetFamily
        ))
    }

    func pad(
        _ edgeSets: [WidgetFamilySet: (Edge.Set, CGFloat)],
        widgetFamily: WidgetFamily? = nil
    ) -> some View {
        modifier(Pad(
            edgeSets: edgeSets,
            widgetFamily: widgetFamily
        ))
    }

    func pad(
        _ paddings: [WidgetFamilySet: CGFloat],
        widgetFamily: WidgetFamily? = nil
    ) -> some View {
        modifier(Pad(
            paddings: paddings,
            widgetFamily: widgetFamily
        ))
    }
}
