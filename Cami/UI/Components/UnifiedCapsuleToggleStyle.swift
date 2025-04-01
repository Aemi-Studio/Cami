//
//  UnifiedCapsuleToggleStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/03/25.
//

import EventKit
import SwiftUI

struct UnifiedCapsuleToggleStyle: ToggleStyle {
    private(set) var count: Int?

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .center, spacing: 6) {
                textCount(isOn: configuration.isOn)
                    .transition(.blurReplace.combined(with: .opacity).combined(with: .scale))

                configuration.label
                    .labelStyle(.titleOnly)
                    .foregroundStyle(configuration.isOn ? Color.background : Color.primary )
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .frame(alignment: .center)
            }
            .foregroundStyle(.secondary)
            .padding(.leading, configuration.isOn && (count != nil && count! > 0) ? 5 : 11)
            .padding(.trailing, 10)
            .frame(height: size, alignment: .center)
        }
        .buttonStyle(CapsuleGlassButtonStyle(
            color: Color.primary,
            intensity: configuration.isOn ? 0.8 : 0.1
        ))
        .animation(.default, value: configuration.isOn)
    }

    @ScaledMetric private var size: CGFloat = 30
    @ScaledMetric private var innerSize: CGFloat = 20

    func getShape(_ shouldBeCapsule: Bool) -> some View {
        GlassStyle(
            shouldBeCapsule ? AnyShape(.capsule) : AnyShape(.circle),
            color: Color.background,
            intensity: 0.9
        )
    }
    
    @ViewBuilder func textCount(isOn: Bool) -> some View {
        if let count, count > 0, isOn {
            let characterCount = count.description.count
            let hasSeveralCharacters = characterCount > 1
            getShape(hasSeveralCharacters)
                .frame(height: innerSize)
                .frame(minWidth: innerSize)
                .frame(width: hasSeveralCharacters ? (CGFloat(characterCount) * innerSize * 0.5) + 8 : nil)
                .overlay(alignment: .center) {
                    Text(count, format: .number)
                        .foregroundStyle(Color.primary.opacity(0.8))
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .font(.footnote)
                }
        }
    }
}

extension ToggleStyle where Self == UnifiedCapsuleToggleStyle {
    static func unifiedCapsule(count: Int) -> some ToggleStyle {
        UnifiedCapsuleToggleStyle(count: count)
    }

    static var unifiedCapsule: some ToggleStyle {
        UnifiedCapsuleToggleStyle()
    }
}
