//
//  KnowledgeBaseView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI

struct KnowledgeBaseView: View {
    @State private var context = KnowledgeBaseContext()

    var body: some View {
        Group {
            if context.searchResults.isEmpty {
                ContentUnavailableView(
                    String(localized: "knowledgebase.search.noResult"),
                    systemImage: "text.page.badge.magnifyingglass"
                )
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(context.searchResults) { result in
                            KnowledgeBaseItemView(item: result)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .searchable(
            text: $context.searchQuery,
            prompt: String(localized: "knowledgebase.search.callToActionPlaceholder")
        )
        .navigationTitle(String(localized: "knowledgebase.navigationbar.title"))
    }
}
