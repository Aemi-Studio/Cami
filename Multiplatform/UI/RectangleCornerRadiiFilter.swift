//
//  RectangleCornerRadiiFilter.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import SwiftUI

struct RectangleCornerRadiiFilter {

    private(set) var topLeading: Bool
    private(set) var bottomLeading: Bool
    private(set) var bottomTrailing: Bool
    private(set) var topTrailing: Bool

    var leading: Bool { topLeading && bottomLeading }
    var trailing: Bool { topTrailing && bottomTrailing }
    var top: Bool { topLeading && topTrailing }
    var bottom: Bool { bottomLeading && bottomTrailing }

    var all: Bool { leading && trailing }

    init(
        _ all: Bool = true,
        top: Bool = true,
        bottom: Bool = true,
        leading: Bool = true,
        trailing: Bool = true,
        topLeading: Bool = true,
        bottomLeading: Bool = true,
        bottomTrailing: Bool = true,
        topTrailing: Bool = true
    ) {
        self.topLeading = all && top && topLeading && leading
        self.bottomLeading = all && bottom && bottomLeading && leading
        self.bottomTrailing = all && bottom && bottomTrailing && trailing
        self.topTrailing = all && top && topTrailing && trailing
    }

    func apply(to radii: RectangleCornerRadii) -> RectangleCornerRadii {
        .init(
            topLeading: (topLeading ? 1 : 0) * radii.topLeading,
            bottomLeading: (bottomLeading ? 1 : 0) * radii.bottomLeading,
            bottomTrailing: (bottomTrailing ? 1 : 0) * radii.bottomTrailing,
            topTrailing: (topTrailing ? 1 : 0) * radii.topTrailing
        )
    }

    func apply(to radius: CGFloat) -> RectangleCornerRadii {
        .init(
            topLeading: radius * (topLeading ? 1 : 0),
            bottomLeading: radius * (bottomLeading ? 1 : 0),
            bottomTrailing: radius * (bottomTrailing ? 1 : 0),
            topTrailing: radius * (topTrailing ? 1 : 0)
        )
    }
}
