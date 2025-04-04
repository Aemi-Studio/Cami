//
//  BottomBarAvoidancePadding.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct BottomBarAvoidancePadding: ViewModifier {
    @Environment(\.presentation) private var presentation

    func body(content: Content) -> some View {
        content
            .padding(.bottom, presentation.bottomBarSize?.height)
            .safeAreaPadding(.bottom)
    }
}

extension View {
    func avoidBottomBar() -> some View {
        modifier(BottomBarAvoidancePadding())
    }
}
