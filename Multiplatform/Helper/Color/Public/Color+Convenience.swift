//
// Project: ContrastKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Concenience APIs

@available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public extension Color {
    /// Returns a color at level 50 brightness.
    var level50: Color { level(.level50) }

    /// Returns a color at level 100 brightness.
    var level100: Color { level(.level100) }

    /// Returns a color at level 200 brightness.
    var level200: Color { level(.level200) }

    /// Returns a color at level 300 brightness.
    var level300: Color { level(.level300) }

    /// Returns a color at level 400 brightness.
    var level400: Color { level(.level400) }

    /// Returns a color at level 500 brightness.
    var level500: Color { level(.level500) }

    /// Returns a color at level 600 brightness.
    var level600: Color { level(.level600) }

    /// Returns a color at level 700 brightness.
    var level700: Color { level(.level700) }

    /// Returns a color at level 800 brightness.
    var level800: Color { level(.level800) }

    /// Returns a color at level 900 brightness.
    var level900: Color { level(.level900) }

    /// Returns a color at level 950 brightness.
    var level950: Color { level(.level950) }
}
