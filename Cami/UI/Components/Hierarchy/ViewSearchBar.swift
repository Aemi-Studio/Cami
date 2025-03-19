//
//  ViewSearchBar.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/02/25.
//

import SwiftUI

struct ViewSearchBar: View {
    @Environment(\.hierarchy) private var hierarchy

    private var context: ViewContext? {
        hierarchy?.context
    }

    var body: some View {
        HStack(spacing: 0) {
            if let context, context.isSearchPresented {
                @Bindable var context = context
                TextField(context.searchPrompt, text: $context.searchQuery)
                    .textFieldStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                            .stroke(Color.secondary.tertiary, lineWidth: 0.25)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.default, value: context?.isSearchPresented)
    }
}
