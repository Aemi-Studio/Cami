//
//  Modal.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func modal(
        isPresented condition: Binding<Bool>,
        presentationDetents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        sheet(isPresented: condition) {
            CustomModal(
                presentationDetents: presentationDetents,
                content: content
            )
            .colorScheme(.dark)
        }
    }
}

enum NavigationType: CaseIterable {
    case navigationStack
    case viewHierarchy
    case none
}
