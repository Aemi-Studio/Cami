//
//  RectangleCornerRadii.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import SwiftUI

extension RectangleCornerRadii {
    init(_ radius: CGFloat) {
        self = RectangleCornerRadii.init(
            topLeading: radius,
            bottomLeading: radius,
            bottomTrailing: radius,
            topTrailing: radius
        )
    }
    init(leading: CGFloat, trailing: CGFloat) {
        self = RectangleCornerRadii.init(
            topLeading: leading,
            bottomLeading: leading,
            bottomTrailing: trailing,
            topTrailing: trailing
        )
    }
    init(top: CGFloat, bottom: CGFloat) {
        self = RectangleCornerRadii.init(
            topLeading: top,
            bottomLeading: bottom,
            bottomTrailing: bottom,
            topTrailing: top
        )
    }
}
