//
//  BlurredEdges.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import AemiSDR
import SwiftUI

extension View {
    func blurredEdges() -> some View {
        overlay {
            VStack(spacing: 0) {
                VariableBlurView(maxBlurRadius: 2, type: .easeInTopToBottom)
                    .frame(maxHeight: 56)

                Spacer()

                VariableBlurView(maxBlurRadius: 2, type: .easeInBottomToTop)
                    .frame(maxHeight: 48)
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.all)
        }
    }
}
