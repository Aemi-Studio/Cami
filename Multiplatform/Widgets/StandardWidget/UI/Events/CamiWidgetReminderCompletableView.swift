//
//  CamiWidgetReminderCompletableView.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/03/25.
//

import SwiftUI

struct CamiWidgetReminderCompletableView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.tint) private var tint

    private var backgroundStyle: some ShapeStyle {
        tint.quinary.opacity(colorScheme == .light ? 0.4 : 0.8)
    }

    private(set) var size: CGSize

    var body: some View {
        UnevenRoundedRectangle(cornerRadii: .init(leading: size.height, trailing: 0))
            .fill(backgroundStyle)
            .frame(width: size.height, height: size.height)
            .compositingGroup()
    }
}
