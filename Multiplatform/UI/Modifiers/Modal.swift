//
//  Modal.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func modal<Content: View>(
        isPresented condition: Binding<Bool>,
        presentationDetents: Set<PresentationDetent> = [.medium, .large],
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            AppModalBlueprint(
                condition: condition,
                presentationDetents: presentationDetents,
                onDismiss: onDismiss,
                modalContent: content
            )
        )
    }
}

struct AppModalBlueprint<ModalContent>: ViewModifier where ModalContent: View {
    
    @Environment(\.appState) private var appState
    
    @Binding private(set) var condition: Bool
    private(set) var presentationDetents: Set<PresentationDetent> = [.medium, .large]
    private(set) var onDismiss: () -> Void = {}
    @ViewBuilder let modalContent: () -> ModalContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $condition, onDismiss: onDismiss) {
                CustomModal(
                    presentationDetents: presentationDetents,
                    navigationType: .navigationStack,
                    content: modalContent
                )
                .colorScheme(.dark)
                .environment(\.appState, appState)
                .environment(\.data, .shared)
                .environment(\.modal, .shared)
                .environment(\.views, .shared)
                .environment(\.permissions, .shared)
                .environment(\.presentation, .shared)
            }
    }
}

enum NavigationType: CaseIterable {
    case navigationStack
    case none
}
