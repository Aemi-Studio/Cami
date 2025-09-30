//
//  PermissionType.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

protocol PermissionType: Hashable, Sendable, Equatable {
    var title: String { get }
    var systemSettingsPath: String { get }
    var symbolName: String { get }
    var description: String { get }
}
