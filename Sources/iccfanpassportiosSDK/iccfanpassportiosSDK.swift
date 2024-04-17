// The Swift Programming Language
// https://docs.swift.org/swift-book

import WebKit
import SwiftUI

public struct MyWebViewLauncher {
    @available(iOS 13.0, *)
    public static func launchWebView() -> some View {
        // Specify your URL here
        let url = URL(string: "https://starter.mintbase.xyz/")!
        return WebView(url: url)
    }
}

@available(iOS 13.0, *)
private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
