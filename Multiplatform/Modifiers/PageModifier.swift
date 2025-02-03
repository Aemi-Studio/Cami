//
//  PageModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func page(_ page: Page) -> some View {
        id(page)
    }
}
