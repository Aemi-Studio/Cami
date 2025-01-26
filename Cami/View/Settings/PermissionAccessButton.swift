//
//  PermissionAccessButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import SwiftUI

struct PermissionAccessButton: View {

    var name: Notification.Name = .requestAccess

    var body: some View {
        Button {
            //            PermissionModel.center.post(name: self.name, object: self)
        } label: {
            ButtonInnerBody(
                label: "Continue",
                systemImage: "arrow.forward.square",
                radius: 8,
                border: true,
                opacity: 1.0
            )
            .tint(.blue)
        }
    }
}
