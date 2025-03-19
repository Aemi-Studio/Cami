//
//  ViewTopBarButtons.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/02/25.
//

import SwiftUI

extension View {
    func buttons<Content>(@ButtonBuilder content: @escaping () -> Content) -> some View where Content: View {
        set(\.buttons, to: content)
    }
}
