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
    var radius: Double = 16

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
                            HStack(alignment: .center) {
                                Label(
                                    "Exit",
                                    systemImage: "xmark.circle.fill"
                                )
                                .fontWeight(.bold)
                                .font(.title2)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .padding(.trailing, 2)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: Color(white: 0, opacity: 0.175), radius: 10, y: 4)

                        }
                        .tint(.black)
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding()
                    .padding(.bottom)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}
