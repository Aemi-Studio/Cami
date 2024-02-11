//
//  InformationModalView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI

struct InformationModalView: View {

    @State
    private var searchText: String = ""

    var searchResult: [FAQInformation] {
        if searchText == "" {
            return FAQInformationModel.shared.list
        } else {
            var weights: [UUID: Int] = [:]
            for information in FAQInformationModel.shared.list {
                weights.updateValue(
                    information.lookFor(text: searchText),
                    forKey: information.id
                )
            }
            // swiftlint:disable identifier_name
            let sortedWeights = weights.sorted(by: { a, b in a.value < b.value })

            return sortedWeights
                .filter({ i in i.value > -1 })
                .map { information in
                    FAQInformationModel.shared.list.first(where: { i in information.key == i.id })!
                }
            // swiftlint:enable identifier_name
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(searchResult) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(result.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            HStack {
                                Text(result.description)
                                Spacer()
                            }
                        }
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Information")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "What do you want to know?"
        )
    }
}
