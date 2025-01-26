//
//  Locale.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation

extension Locale {

    static var prefered: Locale {
        Locale(identifier: Locale.preferredLanguages.first!)
    }

}
