//
//  SettingsAdditionalInformation.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/11/23.
//

import SwiftUI

struct SettingsAdditionalInformation: View {

    var title: String
    var content: () -> any View

    init(_ title: String, content: @escaping () -> any View ) {
        self.title = title
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title)
                AnyView(content())
            }
        }
    }
}

// #Preview {
//    SettingsAdditionalInformation()
// }
