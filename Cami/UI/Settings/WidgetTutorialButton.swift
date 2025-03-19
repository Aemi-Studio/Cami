//
//  WidgetTutorialButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

struct WidgetTutorialButton: View {
    @State private var isTutorialPresented: Bool = false

    var body: some View {
        Button(
            String(localized: "How to add and edit widgets on iPhone"),
            systemImage: "arrow.up.forward.square"
        ) {
            isTutorialPresented.toggle()
        }
        .buttonStyle(
            .customBorderedButton(
                description: String(localized: "Visit Apple Support"),
                outline: true
            )
        )
        .sheet(isPresented: $isTutorialPresented) {
            SafariView(url: .init(string: "https://support.apple.com/en-us/HT207122")!)
        }
    }
}
