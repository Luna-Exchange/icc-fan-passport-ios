//
//  File.swift
//  
//
//  Created by Computer on 4/17/24.
//

import WebKit
import SwiftUI

public struct ICCWebViewLauncher {
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
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update any properties of the web view if needed
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // Handle navigation failure error
            print("Failed to load web view: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            // Handle navigation action (e.g., allow or deny navigation)
            decisionHandler(.allow, preferences)
        }
    }
}

