//
//  CamiWidgetView.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI

struct CamiWidgetView : View {

    let entry: CamiWidgetEntry

    init(for entry: CamiWidgetEntry) {
        self.entry = entry
    }

    var body: some View {

        ZStack {

            VStack(spacing: 6) {

                CamiWidgetHeader()
                

                Color.clear
                    .overlay(alignment:.top) {
                        CamiWidgetEvents()
                            .accessibilityAddTraits(.updatesFrequently)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(6)

            VStack {

                Spacer()

                LinearGradient(
                    colors: [
                        Color(white: 0.1).opacity(0),
                        Color(white: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(maxWidth: .infinity, maxHeight: 64)

            }
        }
        .environmentObject(entry)

    }
}
