//
//  GradientMask.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/03/25.
//

import SwiftUICore

struct GradientMask: View {
    @Environment(\.colorScheme) private var colorScheme

    private var gradientHeight: CGFloat {
        colorScheme == .dark ? 32 : 16
    }

    var body: some View {
        VStack(spacing: 0) {
            Color.black
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: gradientHeight)
        }
    }
}
