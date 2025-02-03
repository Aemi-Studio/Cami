//
//  KnowledgeBaseView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI

struct KnowledgeBaseView: View {

    @Environment(\.navigation) private var navigation

    @State private var context = KnowledgeBaseContext()

    var body: some View {
        if let navigation {
            addButton {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(context.searchResults) { result in
                            KnowledgeBaseItemView(item: result)
                        }
                    }
                    .padding(.horizontal)
                    .avoidBottomBar()
                }
                .navigationTitle(String(localized: "knowledgebase.navigationbar.title"))
                .navigationBarTitleDisplayMode(.automatic)
                .searchable(
                    query: $context.searchQuery,
                    isPresented: navigation.isSearchFocusedBinding,
                    prompt: String(localized: "knowledgebase.search.callToActionPlaceholder")
                )
            }
        }
    }

    private func toggleSearchFocus() {
        withAnimation {
            navigation?.isSearchFocused.toggle()
        }
    }

    private func addButton(@ViewBuilder content: () -> some View) -> some View {
        content()
            .buttons {
                if navigation?.isSearchFocused == .some(true) {
                    Button(
                        String(localized: "knowledgebase.search.closeSearchButton"),
                        systemImage: "xmark",
                        action: toggleSearchFocus
                    )
                } else {
                    Button(
                        String(localized: "knowledgebase.search.focusSearchButton"),
                        systemImage: "magnifyingglass",
                        action: toggleSearchFocus
                    )
                }
            }
    }
}

struct KnowledgeBaseItemView: View {

    let item: KnowledgeBaseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(item.description)
        }
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12))
    }
}
