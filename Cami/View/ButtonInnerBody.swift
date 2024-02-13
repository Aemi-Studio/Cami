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
    var radius: Double = 16
    var border: Bool = false
    var opacity: Double = 0.1
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
                    if opacity < 1.0 {
                        Text(label)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    } else {
                        Text(label)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                    }

                    if let description = description {
                        if opacity < 1 {
                            Text(description)
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.tint.opacity(0.8))
                        } else {
                            Text(description)
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .accessibilityHidden(true)
                .multilineTextAlignment(alignment ?? .leading)
            }
            if noIcon != true {
                Spacer()
                VStack(alignment: .center) {
                    if opacity < 1 {
                        Image(systemName: systemImage ?? "arrow.up.forward.square")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: systemImage ?? "arrow.up.forward.square")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial.opacity(0.5))
        .background(.tint.opacity(opacity))
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .overlay {
            if border == true {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.tint, lineWidth: 0.5)
                    .foregroundStyle(.clear)
            } else {
                EmptyView()
            }
        }
    }
}
