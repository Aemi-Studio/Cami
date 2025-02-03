//
//  NavigationPageButtonsModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/02/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func buttons<Content>(@ButtonBuilder content: @escaping () -> Content) -> some View where Content: View {
        setNavigationPage(\.buttons, to: content)
    }
}
