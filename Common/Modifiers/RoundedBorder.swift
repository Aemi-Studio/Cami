//
//  RoundedBorder.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct RoundedBorder: ViewModifier {

    var color: CGColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    var last: Bool = false

    private let standardCornerRadius: Double = 4
    private let bottomCornerRadius: Double = 18
    private let strokeWidth: Double = 0

    init(_ color: CGColor, last: Bool = false) {
        self.color = color
        self.last = last
    }

    func body(content: Content) -> some View {
        if last {
            content
                .padding(.vertical,2)
                .padding(.horizontal,8)
                .background(.clear)
                .background(Color(cgColor: color).opacity(0.1))
                .overlay {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: standardCornerRadius,
                        bottomLeading: bottomCornerRadius,
                        bottomTrailing: bottomCornerRadius,
                        topTrailing: standardCornerRadius
                    ) )
                    .stroke(Color(cgColor: color).opacity(0.1),lineWidth: strokeWidth)
                }
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: standardCornerRadius,
                    bottomLeading: bottomCornerRadius,
                    bottomTrailing: bottomCornerRadius,
                    topTrailing: standardCornerRadius
                ) ) )
        } else {
            content
                .padding(.vertical,2)
                .padding(.horizontal,4)
                .background(.clear)
                .background(Color(cgColor: color).opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: standardCornerRadius)
                        .stroke(Color(cgColor: color).opacity(0.1),lineWidth: strokeWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
        }
    }
}

extension View {
    func roundedBorder(_ color: CGColor, last: Bool = false) -> some View {
        modifier(RoundedBorder(color, last: last))
    }
}


