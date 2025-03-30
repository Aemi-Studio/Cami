//
//  PresentationContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import EventKit
import SwiftUI

@Observable
final class PresentationContext {
    static let shared: PresentationContext = .init()

    var topBarSize: CGSize? = .zero

    let topBarHeightRange: (minimum: CGFloat, maximum: CGFloat) = (32, 48)
    var scaleFactor: CGFloat = 1
    var scaledTopBarHeight: CGFloat {
        scaleFactor.mapped(from: (0, 1), to: topBarHeightRange)
    }

    var safeScaledTopBarHeight: CGFloat {
        scaledTopBarHeight + (UIApplication.currentWindow?.safeAreaInsets.top ?? 0) + 16
    }

    var topBlurHeight: CGFloat {
        topBarHeightRange.maximum + (UIApplication.currentWindow?.safeAreaInsets.top ?? 0)
    }

    var topBlurRadius: CGFloat {
        scaleFactor.mapped(from: (0, 1), to: (5, 10))
    }

    var bottomBarSize: CGSize? = .zero
    var keyboardSize: CGFloat? = .zero
}

extension EnvironmentValues {
    @Entry var presentation: PresentationContext = .shared
}
