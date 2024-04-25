//
//  File.swift
//  
//
//  Created by Computer on 4/25/24.
//

// ICCWebView.swift

import Foundation
import UIKit
import WebKit

public class ICCWebView: UIViewController, WKNavigationDelegate {
    public var webView: WKWebView!
    private var baseUrlString = "https://icc-fan-passport-staging.vercel.app/"
    private var activityIndicator: UIActivityIndicatorView!
    
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
    
    private func setupActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            // Fallback on earlier versions
        }
            activityIndicator.center = view.center
            activityIndicator.color = .blue
            view.addSubview(activityIndicator)
        }

    private func showActivityIndicator() {
            activityIndicator.startAnimating()
        }

    private func hideActivityIndicator() {
            activityIndicator.stopAnimating()
        }
    
    public func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    public func startSDKOperations() {
        encryptAuthToken(authToken: authToken) { encryptedToken in
            let urlString = "\(self.baseUrlString)?passport_access=\(encryptedToken)"
            if let url = URL(string: urlString) {
                self.webView.load(URLRequest(url: url))
            } else {
                print("Error: Invalid URL")
            }
        }
    }

    private func encryptAuthToken(authToken: String, completion: @escaping (String) -> Void) {
        // Prepare the request
        let url = URL(string: "http://icc-fan-passport-stg-env.eba-tptrhhya.us-east-1.elasticbeanstalk.com/auth/encode")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        showActivityIndicator()
        
        // Prepare the request body
        let requestBody: [String: String] = [
            "authToken": authToken
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Parse the response
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let encryptedToken = json["token"] {
                // Call completion handler with encrypted token
                completion(encryptedToken)
                self.hideActivityIndicator()
            } else {
                print("Error: Unable to parse response")
                self.hideActivityIndicator()
            }
        }
        task.resume()
    }
    
    // WKNavigationDelegate methods...
}


