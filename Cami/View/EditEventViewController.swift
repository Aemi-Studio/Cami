//
//  EditEventView.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/01/24.
//

import SwiftUI
import EventKitUI

struct EditEventViewController: UIViewControllerRepresentable {

    @Environment(\.dismiss)
    var dismiss: DismissAction

    var event: EKEvent

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, EKEventEditViewDelegate {

        var parent: EditEventViewController

        init(_ controller: EditEventViewController) {
            self.parent = controller
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            self.parent.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = EventHelper.store
        eventEditViewController.editViewDelegate = context.coordinator
        return eventEditViewController
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
}
