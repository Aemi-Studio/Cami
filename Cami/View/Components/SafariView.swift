//
//  SafariView.swift
//  Cami
//
//  Created by Guillaume Coquard on 31/01/25.
//

import SwiftUI
import SafariServices

#if os(iOS)

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariView>
    ) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {
        // No need to update the view controller
    }
}
#endif
