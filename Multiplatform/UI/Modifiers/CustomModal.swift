//
//  CustomModal.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/03/25.
//

import SwiftUI

struct CustomModal<Content>: View where Content: View {
    @ViewBuilder private var content: () -> Content
    @State private var selectedDetent: PresentationDetent
    private let navigationType: NavigationType
    private let presentationDetents: Set<PresentationDetent>

    init(
        presentationDetents: Set<PresentationDetent>,
        navigationType: NavigationType = .none,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.presentationDetents = presentationDetents
        self.selectedDetent = presentationDetents.min() ?? .medium
        self.navigationType = navigationType
        self.content = content
    }

    private var shape: some Shape {
        UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                top: 10,
                bottom: UIApplication.currentScreen?.displayCornerRadius ?? 0
            )
        )
    }

    private func modalStack(@ViewBuilder content: () -> some View) -> some View {
        ZStack {
            GlassStyle(
                shape,
                color: .white,
                lineWidth: 0,
                intensity: 0.05,
                radius: 20
            )
            .ignoresSafeArea(.all)

            content()
                .environment(\.viewKind, .sheet)
                .safeAreaPadding(.bottom)

            GlassStyle(
                shape,
                lineWidth: 1,
                intensity: 0,
                radius: 0
            )
            .ignoresSafeArea(.all)
            .padding(0.25)
            .padding(.bottom, 0.125)
        }
        .ignoresSafeArea(.all)
        .presentationBackground(.clear)
        .presentationDetents(presentationDetents, selection: $selectedDetent)
        .onDisappear { selectedDetent = .medium }
        .colorScheme(.dark)
    }

    var body: some View {
        modalStack {
            switch navigationType {
                case .navigationStack:
                    NavigationStack {
                        AnyView(content())
                            .scrollContentBackground(.hidden)
                            .navigationStackStyleReset()
                    }
                case .none:
                    AnyView(content())
            }
        }
    }
}

extension PresentationDetent: @retroactive Comparable {
    public static func < (lhs: PresentationDetent, rhs: PresentationDetent) -> Bool {
        lhs.order < rhs.order
    }

    var order: CGFloat {
        switch self {
            case .medium: 0
            case .large: 1
            default: 2
        }
    }
}
