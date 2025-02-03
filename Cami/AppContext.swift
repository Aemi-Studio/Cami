//
//  AppContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation
import UIKit

enum AppContext {
    enum Destination {
        case settings
    }
}

extension AppContext {
    static func open(_ destination: Destination) {
        switch destination {
        case .settings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
