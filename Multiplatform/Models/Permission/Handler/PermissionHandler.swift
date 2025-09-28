//
//  PermissionHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

import Foundation

@PermissionActor
protocol PermissionHandler: Sendable, Loggable {
    var status: PermissionStatus { get async }
    
    func checkStatus() async -> PermissionStatus
    
    func request() async -> PermissionStatus
}
