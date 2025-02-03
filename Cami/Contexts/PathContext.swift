//
//  PathContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI

@Observable
@MainActor final class PathContext {

    static let shared: PathContext = .init()

    private(set) var path: [Page] = []

    var controller: HomeViewController!

    private init(_ path: [Page] = [.today]) {
        self.path = path
        controller = HomeViewController(self)
    }

    func push(_ page: Page) {
        self.path.append(page)
    }

    func pop() {
        self.path.removeLast()
    }
}

extension EnvironmentValues {
    @Entry var path: PathContext?
}
