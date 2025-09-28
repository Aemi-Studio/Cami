//
//  HybridWidgetView.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import AemiUI
import SwiftUI

struct HybridWidgetView: View {
    typealias Entry = StandardWidgetEntry

    private let entry: Entry
    private let useLightweightMode: Bool

    init(for entry: Entry) {
        self.entry = entry
        // Enable lightweight mode for memory optimization
        // Can be controlled via developer settings or configuration
        let memoryThreshold = 20 * 1024 * 1024 // 20MB threshold
        self.useLightweightMode = entry.configuration.useLightweightMode ||
                                  MemoryProfiler.shared.getCurrentMemoryUsage() > memoryThreshold
    }

    var body: some View {
        Group {
            if useLightweightMode {
                LightweightWidgetView(for: entry)
                    .task {
                        MemoryProfiler.shared.profileMemoryUsage("Lightweight Widget Loaded")
                    }
            } else {
                CamiWidgetView(for: entry)
                    .task {
                        MemoryProfiler.shared.profileMemoryUsage("Standard Widget Loaded")
                    }
            }
        }
        .task {
            // Log memory usage for debugging
            _ = MemoryProfiler.shared.checkWidgetMemoryLimit()
        }
    }
}
