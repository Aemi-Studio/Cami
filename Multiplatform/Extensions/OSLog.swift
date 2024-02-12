//
//  OSLog.swift
//  Cami
//
//  Created by Guillaume Coquard on 12/02/24.
//

import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let views = Logger(subsystem: subsystem, category: "ViewModel()")
    static let perms = Logger(subsystem: subsystem, category: "PermissionModel()")
}
