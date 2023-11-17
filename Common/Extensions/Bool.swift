//
//  Bool.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import Foundation

extension Bool {
    init(_ integer: IntegerLiteralType) {
        self.init(integer > 0)
    }

    init(_ authorizationStatus: AuthorizationSet.Status) {
        self.init(authorizationStatus.rawValue)
    }
}
