//
//  ModalsViewModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 29/03/25.
//

import SwiftUI

struct ModalSheetSetupViewModifier: ViewModifier {
    @Environment(\.modal) private var modal
    
    private var navigationType: NavigationType {
        switch modal.menu {
            default: .navigationStack
        }
    }
    
    func body(content: Content) -> some View {
        @Bindable var modal = modal
        content
            .modal(isPresented: $modal.menu.bool, navigationType: navigationType, onDismiss: ({ modal.close() })) {
                if let view = modal.menu.view {
                    AnyView(view())
                        .defaultModalPresentation(context: modal)
                }
            }
            .environment(\.openModal, modal.open)
    }
}

extension View {
    func setupModals() -> some View {
        modifier(ModalSheetSetupViewModifier())
    }
}

private extension View {
    func defaultModalPresentation(context: ModalSheetContext) -> some View {
        presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
            .environment(\.openModal, context.open)
    }
}
