//
//  InformationModalView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI

struct InformationModalView: View {

    @State private var searchText: String = ""
    @State private var searchResult: [FAQInformation] = []

    var body: some View {
        NavigationView {
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
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "What do you want to know?"
            )
            .onChange(of: searchText) { _, _ in
                Task.detached {
                    let searchResult = await updateResult(for: searchText)
                    Task { @MainActor in
                        self.searchResult = searchResult
                    }
                }
            }
            .task {
                let searchResult = await updateResult(for: searchText)
                Task { @MainActor in
                    self.searchResult = searchResult
                }
            }
        }
    }

    private func updateResult(for searchText: String) async -> [FAQInformation] {
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
            let sortedWeights = weights.sorted(by: { $0.value < $1.value })

            return sortedWeights
                .filter({ $0.value > -1 })
                .map { information in
                    FAQInformationModel.shared.list.first(where: { information.key == $0.id })!
                }
        }
    }
}
