//
//  NavigationPresentation.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

enum NavigationPresentation: Hashable, Comparable, Equatable, Sendable, Codable {
    case push
    case sheet
    case fullScreenCover
}
