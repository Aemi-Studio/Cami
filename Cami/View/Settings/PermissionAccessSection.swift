//
//  PermissionAccessSection.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import SwiftUI

struct PermissionAccessSection: View {

    var status: Access.Status
    var title: String
    var label: String
    var notificationName: Notification.Name
    var description: String
    var restrictedDescription: String
    var radius: Double = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Group {
                    Text(title)
                        .font(.title2)

                    if status == .authorized {
                        Label(
                            label,
                            systemImage: "checkmark.circle.fill"
                        )
                        .foregroundStyle(.green)
                        .labelStyle(.iconOnly)
                    }
                }
                .fontWeight(.semibold)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(description)
            }
            .frame(maxHeight: .infinity)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.foreground.secondary)
            .multilineTextAlignment(.leading)

            switch status {
            case .none, .notDetermined:
                PermissionAccessButton(name: notificationName)
            case .authorized:
                EmptyView()
            case .restricted:
                PermissionSettingsFallbackButton(description: restrictedDescription)
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
