//
//  Modal.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func modal(isPresented condition: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) -> some View {
        self.sheet(isPresented: condition) {
            NavigationStack {
                content()
                    .configureEnvironmentValues()
                    .environment(\.viewKind, .sheet)
            }
        }
    }
}
