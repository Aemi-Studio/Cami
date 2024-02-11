//
//  PermissionAccessButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import SwiftUI

struct PermissionAccessButton: View {

    var name: Notification.Name?

    var body: some View {
        Button {
            if let name = self.name {
                NotificationCenter.default.post(name: name, object: nil)
            }
        } label: {
            ButtonInnerBody(
                label: "Authorize",
                radius: 8,
                border: true,
                noIcon: true
            )
            .tint(.blue)
        }
    }
}
