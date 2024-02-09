//
//  InformationModalView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//
// swiftlint:disable identifier_name

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
                    information.search(text: searchText),
                    forKey: information.id
                )
            }
            var sortedWeights = weights.sorted(by: { a, b in
                return a.value > b.value
            })
            var results: [FAQInformation] = sortedWeights
                .filter({ i in i.value > -1 })
                .map { information in
                    FAQInformationModel.shared.list.first(where: { i in information.key == i.id })!
                }
            return results
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(searchResult) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(result.description)
                        }
                        .frame(maxHeight: .infinity)
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
