//
//  ViewKind.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

extension EnvironmentValues {
    enum ViewKind {
        case standard
        case sheet
        case fullscreen
    }
    @Entry var viewKind: ViewKind? = .standard
}
