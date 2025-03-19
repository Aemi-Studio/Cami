//
//  WidgetPreviewView.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import SwiftUI

struct WidgetPreviewView: View {

    @State private var entry: StandardWidgetEntry?
    private let radius = 0.13333 * 170

    var body: some View {
        ScrollView(.vertical) {
            if let entry {
                VStack {
                    ForEach(WidgetSize.allCases) { widgetSize in
                        ZStack {
                            CamiWidgetView(for: entry)
                                .frame(width: widgetSize.size.width, height: widgetSize.size.height)
                                .environment(\.customWidgetFamily, widgetSize.custom)
                                .background(Color(white: 0.1))
                                .clipShape(.rect(cornerRadius: radius))
                                .overlay {
                                    RoundedRectangle(cornerRadius: radius)
                                        .fill(.clear)
                                        .stroke(Color.primary.quinary.opacity(0.5), lineWidth: 0.5)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 10, y: 3)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        .scrollClipDisabled()
        .task { entry = .default }
    }
}
