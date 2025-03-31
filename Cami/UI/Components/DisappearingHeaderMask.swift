//
//  DisappearingHeaderMask.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import SwiftUI

struct DisappearingHeaderMask: View {
    @Environment(\.presentation)
    private var presentation

    let height: CGFloat?

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(.clear)
                .background {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .clear, location: 0),
                            Gradient.Stop(color: .black.opacity(0.2), location: 0.5),
                            Gradient.Stop(color: .black, location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                }
                .frame(height: height ?? presentation.topBarSize?.height)
            Rectangle()
                .fill(Color.black)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
