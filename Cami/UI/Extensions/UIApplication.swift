//
//  UIApplication.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/03/25.
//

import UIKit

extension UIApplication {
    static var currentWindow: UIWindow? {
        shared
            .connectedScenes
            .filter { $0.activationState.rawValue >= 0 }
            .sorted { $0.activationState.rawValue < $1.activationState.rawValue }
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.keyWindow }
            .first
    }

    static var currentScene: UIWindowScene? {
        currentWindow?.windowScene
    }

    static var currentScreen: UIScreen? {
        currentWindow?.screen
    }
}
