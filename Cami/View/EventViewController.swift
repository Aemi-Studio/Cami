//
//  EventViewController.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/01/24.
//

import SwiftUI
import EventKitUI

struct EventViewController: UIViewControllerRepresentable {

    @Environment(\.dismiss)
    var dismiss: DismissAction

    var event: EKEvent

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, EKEventViewDelegate {

        var parent: EventViewController

        init(_ controller: EventViewController) {
            self.parent = controller
        }

        func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
            self.parent.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> EKEventViewController {
        let eventEditViewController = EKEventViewController()
        eventEditViewController.event = event
        eventEditViewController.delegate = context.coordinator
        return eventEditViewController
    }

    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {}
}
