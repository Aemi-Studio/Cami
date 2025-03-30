//
//  UnifiedCapsuleToggleStyle.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/03/25.
//

import EventKit
import SwiftUI

struct UnifiedCapsuleToggleStyle: ToggleStyle {
    
    private(set) var count: Int? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 6) {
                textCount(isOn: configuration.isOn)
                    .id(configuration.isOn)
                    .transition(.blurReplace.combined(with: .opacity).combined(with: .scale))
                
                configuration.label
                    .labelStyle(.titleOnly)
                    .foregroundStyle(Color.primary)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
            }
            .foregroundStyle(.secondary)
            .padding(.leading, configuration.isOn && (count != nil && count! > 1) ? 6 : 10)
            .padding(.trailing, 10)
            .frame(height: size)
        }
        .buttonStyle(CapsuleGlassButtonStyle(
            color: configuration.isOn ? Color.accentColor : Color.primary,
            intensity: configuration.isOn ? 0.4 : 0.1
        ))
        .animation(.default, value: configuration.isOn)
    }
    
    @ScaledMetric private var size: CGFloat = 30
    @ScaledMetric private var innerSize: CGFloat = 18
    
    @ViewBuilder func textCount(isOn: Bool) -> some View {
        if let count, count > 0, isOn {
            Text(count, format: .number)
                .foregroundStyle(.clear)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.footnote)
                .frame(height: innerSize)
                .frame(minWidth: innerSize)
                .background(isOn ? Color.white : .clear)
                .clipShape("\(count)".count == 1 || !isOn ? AnyShape(.circle) : AnyShape(.capsule))
                .overlay {
                    if isOn {
                        Text(count, format: .number)
                            .foregroundStyle(Color.primary)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .font(.footnote)
                            .blendMode(.destinationOut)
                    }
                }
                .compositingGroup()
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
