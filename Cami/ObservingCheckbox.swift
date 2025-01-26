//
//  ObservingCheckbox.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

struct ObservingCheckbox<T>: View {

    let value: T
    let symbolProvider: (T) -> CheckboxSymbol?
    let backgroundColorProvider: (T) -> Color?

    @ScaledMetric
    private var size: CGFloat = 24

    private var symbol: String? {
        symbolProvider(value)?.rawValue
    }

    private var backgroundColor: Color {
        backgroundColorProvider(value) ?? .gray
    }

    private var isKnown: Bool {
        symbol != nil
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .foregroundStyle(backgroundColor)
            .frame(width: size, height: size)
            .if(isKnown) {
                $0.overlay {
                    Image(systemName: symbol!)
                        .foregroundStyle(.white)
                        .font(.callout)
                        .fontWeight(.bold)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary.quaternary, lineWidth: 0.5)
            }
    }
}
