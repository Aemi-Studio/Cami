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
        navigationType: NavigationType = .navigationStack,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            AppModalBlueprint(
                condition: condition,
                presentationDetents: presentationDetents,
                navigationtype: navigationType,
                onDismiss: onDismiss,
                modalContent: content
            )
        )
    }
}

struct AppModalBlueprint<ModalContent>: ViewModifier where ModalContent: View {
    @Environment(\.appState) private var appState

    @Environment(PermissionManager.self) private var permissionManager

    @Binding private(set) var condition: Bool
    private(set) var presentationDetents: Set<PresentationDetent> = [.medium, .large]
    private(set) var navigationtype: NavigationType = .navigationStack
    private(set) var onDismiss: () -> Void = { ModalSheetContext.shared.close() }
    @ViewBuilder let modalContent: () -> ModalContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $condition, onDismiss: onDismiss) {
                CustomModal(
                    presentationDetents: presentationDetents,
                    navigationType: navigationtype,
                    content: modalContent
                )
                .colorScheme(.dark)
                .environment(\.appState, appState)
                .environment(\.data, .shared)
                .environment(\.modal, .shared)
                .environment(\.views, .shared)
                .environment(\.presentation, .shared)
                .environment(permissionManager)
            }
    }
}

enum NavigationType: CaseIterable {
    case navigationStack
    case none
}
