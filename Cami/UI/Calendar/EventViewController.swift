//
//  EventViewController.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/01/24.
//

import EventKitUI
import SwiftUI

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
            parent = controller
        }

        func eventViewController(_: EKEventViewController, didCompleteWith _: EKEventViewAction) {
            parent.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> EKEventViewController {
        let eventEditViewController = EKEventViewController()
        eventEditViewController.event = event
        eventEditViewController.delegate = context.coordinator
        return eventEditViewController
    }

    func updateUIViewController(_: EKEventViewController, context _: Context) {}
}
