//
//  Locale.swift
//  Cami
//
//  Created by Guillaume Coquard on 12/09/24.
//

import Foundation

extension Locale {

    static var prefered: Locale {
        Locale(identifier: Locale.preferredLanguages.first!)
    }

}
