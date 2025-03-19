//
//  WidgetsRefreshButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI
import WidgetKit

struct WidgetsRefreshButton: View {
    var body: some View {
        Button(String(localized: "button.refreshWidgets"), systemImage: "arrow.clockwise") {
            WidgetCenter.shared.reloadAllTimelines()
        }
        .buttonStyle(.primaryWithOutline)
    }
}
