//
//  SafariView.swift
//  Cami
//
//  Created by Guillaume Coquard on 31/01/25.
//

import SafariServices
import SwiftUI

#if os(iOS)

    struct SafariView: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(
            context _: UIViewControllerRepresentableContext<SafariView>
        ) -> SFSafariViewController {
            SFSafariViewController(url: url)
        }

        func updateUIViewController(
            _: SFSafariViewController,
            context _: UIViewControllerRepresentableContext<SafariView>
        ) {
            // No need to update the view controller
        }
    }
#endif
