//
//  EventPermissionHandler.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

import EventKit

@PermissionActor
protocol EventPermissionHandler: PermissionHandler {
    var store: EKEventStore { get }
    
    init()
    init(otherHandler: any EventPermissionHandler)
}
