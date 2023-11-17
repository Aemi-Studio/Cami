//
//  EdgeInsets.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import SwiftUI

extension EdgeInsets {
    init(all: CGFloat) {
        self = EdgeInsets(
            top: all,
            leading: all,
            bottom: all,
            trailing: all
        )
    }

    init(vertical: CGFloat, horizontal: CGFloat) {
        self = EdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }
}
