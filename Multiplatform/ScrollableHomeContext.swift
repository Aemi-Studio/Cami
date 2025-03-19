//
//  ScrollableHomeContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/01/25.
//

import SwiftUI

// swiftlint:disable syntactic_sugar
// swiftformat:disable typeSugar

@Observable
@MainActor final class HomeViewController {
    private(set) var scrollProxy: Optional<ScrollViewProxy>

    var scrollPosition: Optional<Page>

    private(set) var context: PathContext

    init(_ context: PathContext) {
        self.context = context
        scrollPosition = context.path.first
        scrollProxy = nil
    }

    func attach(_ proxy: ScrollViewProxy) {
        scrollProxy = proxy
    }
}

extension EnvironmentValues {
    @Entry var homeViewController: HomeViewController?
}
