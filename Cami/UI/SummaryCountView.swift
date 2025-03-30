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
    @Binding private(set) var bound: Bool
    
    var body: some View {
        Toggle(isOn: $bound) {
            Text(title)
        }
        .toggleStyle(.unifiedCapsule(count: count))
    }
}
