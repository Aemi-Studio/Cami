//
//  BlurryScrollView.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import SwiftUI

struct BlurryScrollView<Content: View>: View {

    init(
        blurHeight: CGFloat = UIApplication.currentWindow?.safeAreaInsets.top ?? 0,
        blurRadius: CGFloat = 10,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.blurHeight = blurHeight
        self.blurRadius = blurRadius
        self.content = content
    }

    private let blurHeight: CGFloat
    private let blurRadius: CGFloat
    private let content: () -> Content

    var body: some View {
        ScrollView {
            content()
        }
        .scrollClipDisabled()
        .mask {
            VStack(spacing: 0) {
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                    .frame(height: blurHeight)
                Rectangle()
                    .fill(.black)
            }
        }
        .overlay(alignment: .top) {
            VariableBlurView(maxBlurRadius: blurRadius, direction: .blurredTopClearBottom)
                .frame(height: blurHeight)
        }
    }
}
