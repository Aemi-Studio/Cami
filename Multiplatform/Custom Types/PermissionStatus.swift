//
//  PermissionStatus.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import Foundation

enum PermissionStatus: Int {
    case authorized = 1
    case restricted = 0
    case notDetermined = -1
}
