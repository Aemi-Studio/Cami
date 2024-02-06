//
//  ButtonInnerBody.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/02/24.
//

import SwiftUI

struct ButtonInnerBody: View {

    var label: String
    var description: String?
    var systemImage: String?
    var radius: Double?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Group {
                    Text(label)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.foreground)
                        .accessibilityHidden(true)

                    if let description = description {
                        Text(description)
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(.foreground.opacity(0.8))
                    }
                }
                .multilineTextAlignment(.leading)
            }
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: systemImage ?? "arrow.up.forward.square")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.5))
        .background(.foreground.quinary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: radius ?? 16))
    }
}

#Preview {
    ButtonInnerBody(label: "Button")
}
