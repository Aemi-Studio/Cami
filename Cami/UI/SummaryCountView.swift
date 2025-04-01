//
//  SummaryCountView.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct SummaryCountView: View {
    private(set) var title: String
    private(set) var count: Int
    @Binding private(set) var binding: Bool

    var body: some View {
        Toggle(isOn: $binding) {
            Text(title)
        }
        .toggleStyle(.unifiedCapsule(count: count))
    }
}
