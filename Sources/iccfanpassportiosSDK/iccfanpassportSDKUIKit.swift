//
//  File.swift
//  
//
//  Created by Computer on 4/17/24.
//

import UIKit
import WebKit

class ICCWebViewLaunch: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    
   
    private let url: URL = URL(string: "https://starter.mintbase.xyz/")!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)

       
        webView.load(URLRequest(url: url))
       
        setupAccessibility()
        
        
        //provideDocumentation()
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print("Failed to load web view: \(error.localizedDescription)")
    }

    // MARK: - Accessibility

    private func setupAccessibility() {
        webView.accessibilityLabel = "Web Content" // Accessibility label
    }

//    // MARK: - Documentation
//
//    private func provideDocumentation() {
//        // Provide documentation for the usage and configuration options
//    }
}
