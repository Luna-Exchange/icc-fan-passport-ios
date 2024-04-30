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
    
    public init(authToken: String, name: String, email: String) {
        self.authToken = authToken
        self.name = name
        self.email = email
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
    //Updated to run on the main thread
    public func startSDKOperations() {
        encryptAuthToken(authToken: authToken) { encryptedToken in
            DispatchQueue.main.async {
                let urlString = "\(self.baseUrlString)?passport_access=\(encryptedToken)"
                if let url = URL(string: urlString) {
                    self.webView.load(URLRequest(url: url))
                } else {
                    print("Error: Invalid URL")
                }
            }
        }
    }

    private func encryptAuthToken(authToken: String, completion: @escaping (String) -> Void) {
        // Prepare the request
        let url = URL(string: "https://icc-fan-passport-stg-api.insomnialabs.xyz/auth/encode")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the request body
        let requestBody: [String: String] = [
            "authToken": authToken,
            "name": name,
            "email": email
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
            } else {
                print("Error: Unable to parse response")
            }
        }
        task.resume()
    }
    
    // WKNavigationDelegate methods...
}


