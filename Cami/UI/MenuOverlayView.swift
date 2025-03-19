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
        presentation.menu != .none
    }

    private var minOpacity: CGFloat {
        !isMenuPresented ? 0 : 0.5
    }

    var body: some View {
        Color.clear
            .background(alignment: .bottom) {
                Group {
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
                .animation(.default, value: isMenuPresented)
                .animation(.default, value: presentation.isMenuPresented)
            }
    }
}
