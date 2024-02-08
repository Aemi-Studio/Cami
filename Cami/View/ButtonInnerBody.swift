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
    var border: Bool? = false
    var alignment: TextAlignment? = .leading
    var halignment: HorizontalAlignment {
        return switch alignment {
        case .center:
            .center
        case .trailing:
            .trailing
        default:
            .leading
        }
    }
    var noIcon: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: halignment, spacing: 3) {
                Group {
                    Text(label)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    if let description = description {
                        Text(description)
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(.tint.opacity(0.8))
                    }
                }
                .multilineTextAlignment(alignment ?? .leading)
            }
            if noIcon != true {
                Spacer()
                VStack(alignment: .center) {
                    Image(systemName: systemImage ?? "arrow.up.forward.square")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial.opacity(0.5))
        .background(.tint.quinary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: radius ?? 16))
        .overlay {
            if border == true {
                RoundedRectangle(cornerRadius: radius ?? 16)
                    .stroke(.tint, lineWidth: 0.5)
                    .foregroundStyle(.clear)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    ButtonInnerBody(label: "Button")
}
