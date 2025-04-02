//
//  AppHeaderUnderlyingMask.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct AppFadeMask: View {
    @Environment(\.presentation) private var presentation
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: presentation.safeScaledTopBarHeight)
            Rectangle()
                .fill(.black)
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: UIApplication.currentWindow?.safeAreaInsets.bottom)
        }
    }
}

extension View {
    func fadeMask() -> some View {
        mask {
            AppFadeMask()
        }
    }
}
