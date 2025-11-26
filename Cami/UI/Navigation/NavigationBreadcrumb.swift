//
//  NavigationBreadcrumb.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

struct NavigationBreadcrumb: View {
    @Environment(AppNavigation.self) private var navigation
    let destination: NavigationDestination
    
    var body: some View {
        HStack(spacing: 4) {
            if let parent = destination.configuration.parent {
                Button {
                    navigation.navigate(to: parent)
                } label: {
                    Label(parent.configuration.id, systemImage: "chevron.left")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.plain)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Text(destination.configuration.id)
                .fontWeight(.medium)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
