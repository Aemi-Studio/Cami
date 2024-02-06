//
//  WebView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/02/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    var url: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = self.url {
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

#Preview {
    WebView()
}
