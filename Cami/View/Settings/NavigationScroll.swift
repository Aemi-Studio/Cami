//
//  NavigationScroll.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

@MainActor
struct NavigationScroll: View {
    typealias Content = (any View)

    @Environment(\.presentation) private var presentation

    @State private var navigation: NavigationContext
    @State private var topBarSize: CGSize? = .zero

    private static let rootId: UUID = .init(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

    private var positionBinding: Binding<UUID?> {
        Binding {
            navigation.path.last?.id ?? Self.rootId
        } set: { _ in }
    }

    func reset() {
        navigation.path.removeAll()
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        navigation = NavigationContext(
            NavigationPage(content: content)
        )
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                Group {
                    ForEach(navigation.path) { page in
                        if let topBarSize, let bottomBarSize = presentation?.bottomBarSize {
                            AnyView(page.content())
                                .scrollClipDisabled()
                                .padding(.top, topBarSize.height)
                                .padding(.bottom, bottomBarSize.height)
                                .avoidBottomBar()
                                .animation(.default, value: topBarSize)
                                .animation(.default, value: bottomBarSize)
                        }
                    }
                }
                .containerRelativeFrame(.horizontal)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
            }
            .scrollTargetLayout()
        }
        .overlay(alignment: .top) {
            NavigationTopBar()
                .update($topBarSize)
        }
        .scrollPosition(id: positionBinding, anchor: .trailing)
        .defaultScrollAnchor(.trailing)
        .scrollClipDisabled()
        .scrollDisabled(true)
        .scrollBounceBehavior(.automatic)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollIndicators(.hidden)
        .animation(.default, value: positionBinding.wrappedValue)
        .environment(\.navigation, navigation)
        .ignoresSafeArea(.all)
        .onDisappear {
            reset()
        }
    }
}
