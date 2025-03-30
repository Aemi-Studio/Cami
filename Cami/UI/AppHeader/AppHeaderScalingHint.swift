//
//  AppHeaderScalingHint.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct AppHeaderScalingHint: View {
    @Environment(\.presentation) private var presentation
    var body: some View {
        @Bindable var presentation = presentation
        Rectangle()
            .fill(.clear)
            .frame(height: presentation.topBlurHeight)
            .track(visibility: $presentation.scaleFactor)
    }
}
