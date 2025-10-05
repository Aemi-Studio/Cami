//
//  NavigationDestination.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

enum NavigationDestination: Hashable, Codable, Equatable, Navigable {
    var id: String { configuration.id }

    case main
    case onboarding
    case settings
}

extension NavigationDestination {
    var configuration: Configuration {
        switch self {
            case .main: "main"
            case .onboarding: "onboarding"
            case .settings: .init(id: "settings", presentation: .sheet)
        }
    }
}
