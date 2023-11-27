//
//  RoundedBorder.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct RoundedBorder: ViewModifier {

    let color: CGColor
    let last: Bool
    let bordered: Bool

    init(
        _ color: CGColor = .init(red: 1, green: 1, blue: 1, alpha: 1),
        last: Bool = false,
        bordered: Bool = false
    ) {
        self.color = color
        self.last = last
        self.bordered = bordered
    }

    private let standardCornerRadius: Double = 4
    private let bottomCornerRadius: Double = 18
    private var strokeWidth: Double {
        get {
            self.bordered ? 2 : 0
        }
    }
    private var opacity: Double {
        get {
            self.bordered ? 0 : 0.1
        }
    }

    func body(content: Content) -> some View {
        if last {
            content
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(.clear)
                .background(Color(cgColor: color).opacity(opacity))
                .overlay {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: standardCornerRadius,
                        bottomLeading: bottomCornerRadius,
                        bottomTrailing: bottomCornerRadius,
                        topTrailing: standardCornerRadius
                    ) )
                    .stroke(Color(cgColor: color).opacity(0.25), lineWidth: strokeWidth)
                }
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: standardCornerRadius,
                    bottomLeading: bottomCornerRadius,
                    bottomTrailing: bottomCornerRadius,
                    topTrailing: standardCornerRadius
                ) ) )
        } else {
            content
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(.clear)
                .background(Color(cgColor: color).opacity(opacity))
                .overlay {
                    RoundedRectangle(cornerRadius: standardCornerRadius)
                        .stroke(Color(cgColor: color).opacity(0.25), lineWidth: strokeWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
        }
    }
}

extension View {
    func roundedBorder(_ color: CGColor, last: Bool = false, bordered: Bool = false) -> some View {
        modifier(RoundedBorder(color, last: last, bordered: bordered))
    }
}
