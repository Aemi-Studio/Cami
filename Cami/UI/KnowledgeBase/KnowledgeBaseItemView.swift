//
//  KnowledgeBaseItemView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/02/25.
//

import SwiftUI

struct KnowledgeBaseItemView: View {
    let item: KnowledgeBaseItem

    var body: some View {
        GlassContentStyle(.rect(cornerRadius: 12)) {
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
        }
    }
}
