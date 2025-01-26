//
//  StorageContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

struct StorageContext {
    @AppStorage("accessWorkInProgressFeatures")
    static var accessWorkInProgressFeatures = false
}
