//
//  AccessToggle.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

struct AccessToggle<A>: View {
    let status: Access.Status
    let title: String
    let description: String
    private(set) var action: (() -> A)?
    private(set) var asyncAction: (() async -> A)?

    private var isValid: Bool { status == .authorized }
    private var isUnknown: Bool { status != .restricted }
    @State private var isDescriptionOpen: Bool = false
    private var isDrawerOpen: Bool { !isValid || isDescriptionOpen }

    private var tint: Color? {
        .accentColor
    }

    var body: some View {
        Button { @MainActor in
            if isValid {
                withAnimation {
                    isDescriptionOpen.toggle()
                }
            } else if isUnknown {
                _ = action?()
                Task { @MainActor in
                    _ = await asyncAction?()
                }
            } else {
                AppContext.open(.settings)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                header
                    .padding(.bottom, 8)
                if isDrawerOpen {
                    Rectangle()
                        .fill(Color.secondary.tertiary)
                        .frame(
                            minHeight: CustomDesign.borderedStrokeWidth,
                            idealHeight: CustomDesign.borderedStrokeWidth
                        )
                        .frame(maxWidth: .infinity)
                        .layoutPriority(100)
                    bottom
                        .padding(.top, 8)
                }
            }
            .padding(.bottom, 8)
        }
        .buttonStyle(.customBorderedButton(
            layout: false,
            backgroundStyle: Color.secondary,
            padding: 0,
            outline: true
        ))
    }

    private var header: some View {
        HStack(spacing: 12) {
            AccessCheckbox(status: status)
            Text(title)
            Spacer()
            callToAction
        }
        .padding([.horizontal, .top])
    }

    @ViewBuilder
    private var callToAction: some View {
        if isValid {
            Label(
                isDrawerOpen ? "Close" : "Details",
                systemImage: "plus"
            )
            .foregroundStyle(Color.primary.tertiary)
            .labelStyle(.iconOnly)
            .font(.title3)
            .rotationEffect(.degrees(isDrawerOpen ? 45 : 0))
        } else {
            HStack {
                if isUnknown {
                    Label(
                        String(localized: "permissions.callToAction.next"),
                        systemImage: "arrow.forward.square.fill"
                    )
                    .labelStyle(.titleOnly)
                } else {
                    Label(
                        String(localized: "permissions.callToAction.review"),
                        systemImage: "arrow.up.right.square.fill"
                    )
                    .labelStyle(.titleAndIcon)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .font(.headline)
            .fontWeight(.medium)
            .background(isUnknown ? tint ?? .blue : .red)
            .clipShape(.rect(cornerRadius: 6))
        }
    }

    private var bottom: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(description)
        }
        .frame(maxHeight: .infinity)
        .font(.caption)
        .foregroundStyle(Color.primary.secondary)
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension AccessToggle {
    init(
        isOn status: Access.Status,
        title: String,
        description: String,
        action: @escaping () -> A
    ) {
        self.status = status
        self.title = title
        self.description = description
        self.action = action
    }

    init(
        isOn status: Access.Status,
        title: String,
        description: String,
        action: @escaping () async -> A
    ) {
        self.status = status
        self.title = title
        self.description = description
        asyncAction = action
    }
}
