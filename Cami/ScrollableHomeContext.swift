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
@MainActor final class ScrollableHomeContext {

    private(set) var scrollProxy: Optional<ScrollViewProxy>

    var scrollPosition: Optional<Page>

    private(set) var pages: [Page]

    init(_ pages: [Page]) {
        self.pages = pages
        self.scrollPosition = pages.first
        self.scrollProxy = nil
    }

    func attach(_ proxy: ScrollViewProxy) {
        self.scrollProxy = proxy
    }
}
