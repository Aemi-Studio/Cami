//
//  AppHeaderUnderlyingMask.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct AppHeaderUnderlyingMask: View {
    @Environment(\.presentation) private var presentation
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: presentation.safeScaledTopBarHeight)
            Rectangle()
                .fill(.black)
        }
    }
}

extension View {
    func headerUnderlyingMask() -> some View {
        mask {
            AppHeaderUnderlyingMask()
        }
    }
}
