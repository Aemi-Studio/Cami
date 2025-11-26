//
//  Navigable.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

protocol Navigable: Identifiable, Hashable, Codable, Sendable, Equatable {
    typealias Configuration = NavigationConfiguration<Self>
    var configuration: Configuration { get }
}
