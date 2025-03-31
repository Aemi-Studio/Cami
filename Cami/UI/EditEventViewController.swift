//
//  EditEventViewController.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/01/24.
//

import EventKitUI
import SwiftUI

struct EditEventViewController: UIViewControllerRepresentable {
    @Environment(\.dismiss)
    var dismiss: DismissAction

    var event: EKEvent

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EditEventViewController

        init(_ controller: EditEventViewController) {
            self.parent = controller
        }

        func eventEditViewController(
            _: EKEventEditViewController,
            didCompleteWith _: EKEventEditViewAction
        ) {
            parent.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = DataContext.shared.store
        eventEditViewController.editViewDelegate = context.coordinator
        return eventEditViewController
    }

    func updateUIViewController(_: EKEventEditViewController, context _: Context) {}
}
