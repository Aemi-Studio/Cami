//
//  InformationsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/02/24.
//

import SwiftUI

struct WidgetHelpView: View {

    @State
    private var isModalPresentedWebView: Bool = false

    var title: String
    var url: String
    var description: String?
    var radius: Double?

    var body: some View {
        Button {
            isModalPresentedWebView.toggle()
        } label: {
            ButtonInnerBody(label: title, description: description, radius: radius)
        }
        .contextMenu {
            Button("Open in your default browser", systemImage: "arrow.up.forward.square") {
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .sheet(isPresented: $isModalPresentedWebView) {
            ZStack {
                WebView(url: URL(string: url)!)
                    .ignoresSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            isModalPresentedWebView.toggle()
                        } label: {
                            Label("Exit", systemImage: "xmark.circle.fill")
                                .fontWeight(.bold)
                                .font(.title2)

                        }
                        .tint(Color(white: 0, opacity: 0.7))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        Spacer()
                    }
                    .padding()

                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    WidgetHelpView(title: "How to add and edit widgets on iPhone", url: "https://support.apple.com/en-us/HT207122", description: "Visit Apple Support.")
}
