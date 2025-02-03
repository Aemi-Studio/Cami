//
//  MenuOverlayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUICore

struct MenuOverlayView: View {
    @Environment(\.presentation) private var presentation

    private var isMenuPresented: Bool {
        presentation?.menu != .some(.none)
    }

    private var minOpacity: CGFloat {
        presentation?.menu == .some(.none) ? 0 : 0.5
    }

    var body: some View {
        Color.clear.safeAreaInset(edge: .bottom) {
            ZStack(alignment: .top) {
                Group {
                    if let presentation {
                        switch presentation.menu {
                        case .settings: CustomSettingsView()
                        default: EmptyView()
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .push(from: .top).combined(with: .opacity)
                ))
                Color.clear.overlay(alignment: .bottom) {
                    BottomBar()
                }
            }
            .background(alignment: .bottom) {
                if isMenuPresented {
                    ZStack {
                        VariableBlurView(maxBlurRadius: 20, direction: .blurredBottomClearTop)
                            .ignoresSafeArea(.all)

                        LinearGradient(
                            colors: [Color.background.opacity(minOpacity), Color.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .frame(maxHeight: isMenuPresented ? .infinity : 0)
                }
            }
        }
    }
}
