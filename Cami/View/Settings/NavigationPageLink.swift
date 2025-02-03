//
//  NavigationPageLink.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct NavigationPageLink: View {
    @Environment(\.navigation) private var path

    typealias Content = (any View)
    typealias Destination = (any View)

    let title: String
    let image: String
    let destination: () -> Destination

    init(
        _ title: String,
        image: String = "chevron.forward",
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.image = image
        self.destination = destination
    }

    var body: some View {
        Button(title, systemImage: image) {
            path?.push(
                NavigationPage(title, content: destination)
            )
        }
        .buttonStyle(.accentWithOutline)
        .disabled(path == nil)
    }
}
