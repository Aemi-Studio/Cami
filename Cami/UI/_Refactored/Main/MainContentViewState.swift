//
//  MainContentViewState.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

/// State object for managing MainContentView's UI state
/// Extracted from the original AppViewState
@Observable
@MainActor
final class MainContentViewState {
    var topBarHeight = CGFloat.zero
    var scrollViewOffset = CGFloat.zero
}