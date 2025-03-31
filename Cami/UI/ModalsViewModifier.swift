//
//  ModalsViewModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 29/03/25.
//

import SwiftUI

struct ModalSheetSetupViewModifier: ViewModifier {
    @Environment(\.modal) private var modal
    func body(content: Content) -> some View {
        @Bindable var modal = modal
        content
            .modal(isPresented: $modal.menu.bool, onDismiss: ({ modal.close() })) {
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

    fileprivate func defaultModalPresentation(context: ModalSheetContext) -> some View {
        presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
            .environment(\.openModal, context.open)
    }
}
