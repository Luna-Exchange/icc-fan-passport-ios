//
//  File.swift
//  
//
//  Created by Computer on 4/25/24.
//

import Foundation
import UIKit
import WebKit



// ICCWebViewLaunch.swift

public class ICCWebView: UIViewController, WKNavigationDelegate {
    public var webView: WKWebView!
    private var authManager: AuthManager = AuthManager()
    public let baseUrlString = "https://icc-fan-passport-staging.vercel.app/"
    
    public var authToken: String
    public var name: String
    public var email: String
    public var username: String
    
    public init(authToken: String, name: String, email: String, username: String) {
        self.authToken = authToken
        self.name = name
        self.email = email
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        startSDKOperations()
    }
    
    public func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    public func startSDKOperations() {
        authManager.StartSDK(authToken: authToken, name: name, email: email, username: username) { encryptedToken in
            let urlString = "\(self.baseUrlString)?passport_access=\(encryptedToken)"
            if let url = URL(string: urlString) {
                self.webView.load(URLRequest(url: url))
            } else {
                print("Error: Invalid URL")
            }
        }
    }

    
//    private func triggerSDKOperations() {
//        authManager.triggerSDK(authToken: authToken, name: name, email: email, username: username) { encryptedToken in
//            let urlString = "\(baseUrlString)?passport_access=\(encryptedToken)"
//            if let url = URL(string: urlString) {
//                webView.load(URLRequest(url: url))
//            } else {
//                print("Error: Invalid URL")
//            }
//        }
//    }
    
    // WKNavigationDelegate methods...
}

