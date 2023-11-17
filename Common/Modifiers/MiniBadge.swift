//
//  MiniBadge.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import SwiftUI
import WidgetKit

struct MiniBadge: ViewModifier {

    var color: Color? = .black

    init(color: Color = .black) {
        self.color = color
    }

    init(cgColor: CGColor?) {
        self.color = Color(
            cgColor: cgColor ?? .init(red: 0, green: 0, blue: 0, alpha: 1)
        )
    }

    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            .foregroundStyle(Color.init(white: 0.1))
            .pad([
                .notSmall: .init(
                    vertical: 2,
                    horizontal: 4
                ),
                .systemSmall: .init(
                    vertical: 4,
                    horizontal: 8
                )
            ])
            .background(self.color)
            .rounded([
                .notSmall: .init(2),
                .systemSmall: .init(
                    topLeading: 2,
                    bottomLeading: 2,
                    bottomTrailing: 2,
                    topTrailing: 8
                )
            ])
    }
}

extension View {
    public func miniBadge(color: Color) -> some View {
        modifier(MiniBadge(color: color))
    }

    public func miniBadge(cgColor: CGColor) -> some View {
        modifier(MiniBadge(cgColor: cgColor))
    }
}
