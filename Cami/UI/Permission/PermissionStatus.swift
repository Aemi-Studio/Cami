//
//  PermissionStatus.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

enum PermissionStatus: Sendable, Equatable {
    /// The user has not yet been asked for permission.
    case notDetermined

    /// The user has explicitly granted permission.
    case authorized

    /// The user has explicitly denied permission.
    case denied

    /// The app is not authorized to use the feature, and the user cannot change this.
    /// (e.g., due to parental controls).
    case restricted
}
