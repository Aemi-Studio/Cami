//
//  StorageContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import SwiftUI

enum StorageContext {
    @AppStorage("accessWorkInProgressFeatures")
    static var accessWorkInProgressFeatures = false
}
