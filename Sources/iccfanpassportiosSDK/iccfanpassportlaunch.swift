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

import UIKit
import WebKit

public class ICCWebView1: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    public var webView: WKWebView!
    private var baseUrlString = "https://icc-fan-passport-staging.vercel.app/"
    private var activityIndicator: UIActivityIndicatorView!
    private var loaderViewController: LoaderViewController?
    
    public var authToken: String
    public var name: String
    public var email: String
    public var initialEntryPoint: PassportEntryPoint
    public var navigateToICCAction: (() -> Void)? // Callback closure
    
    public init(authToken: String, name: String, email: String, initialEntryPoint: PassportEntryPoint) {
        self.authToken = authToken
        self.name = name
        self.email = email
        self.initialEntryPoint = initialEntryPoint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        startSDKOperations(entryPoint: initialEntryPoint) // Default entry point is home
    }
    
    public func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Enable JavaScript
        webView.configuration.preferences.javaScriptEnabled = true
        
        
        // Add script message handler for 'navigateToIcc'
        webView.configuration.userContentController.add(self, name: "navigateToIcc")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Inject JavaScript to handle 'navigate-to-icc' event
        let script = """
            window.addEventListener('navigate-to-icc', function() {
                window.webkit.messageHandlers.navigateToIcc.postMessage(null);
            });
        """
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "navigateToIcc" {
            // Handle the 'navigate-to-icc' event here
            print("Received 'navigate-to-icc' event")
            // Call the callback action
            navigateToICCAction?()
        }
    }
    
    public func startSDKOperations(entryPoint: PassportEntryPoint) {
        showLoader() // Show loader before network call
        
        encryptAuthToken(authToken: authToken) { encryptedToken in
            DispatchQueue.main.async {
                if let url = self.constructURL(forEntryPoint: entryPoint, withToken: encryptedToken) {
                    self.webView.load(URLRequest(url: url))
                } else {
                    print("Error: Invalid URL")
                    self.hideLoader() // Hide loader on error
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
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let statusCode = json["statusCode"] as? Int, statusCode == 200,
               let responseData = json["data"] as? [String: Any],
               let encryptedToken = responseData["token"] as? String {
                // Call completion handler with encrypted token
                completion(encryptedToken)
            } else {
                print("Error: Unable to parse response or token not found")
            }
        }
        task.resume()
    }
    
    private func constructURL(forEntryPoint entryPoint: PassportEntryPoint, withToken token: String) -> URL? {
        let path: String
        switch entryPoint {
            case .onboarding:
                path = "onboarding"
            case .profile:
                path = "profile"
            case .createavatar:
                path = "create-avatar"
            case .challenge:
                path = "challenges"
            case .rewards:
                path = "rewards"
            // Add more cases for additional entry points as needed
        }
        
        let urlString = "\(baseUrlString)\(path)?passport_access=\(token)"
        return URL(string: urlString)
    }
    
    private func showLoader() {
        loaderViewController = LoaderViewController()
        present(loaderViewController!, animated: true, completion: nil)
    }
    
    private func hideLoader() {
        loaderViewController?.dismiss(animated: true, completion: nil)
    }
    
    // Add message handler to WKWebView configuration
//       public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//           if message.name == "navigateToICC" {
//               navigateToICCAction?()
//           }
}

   
    
    
       


    // WKNavigationDelegate methods...

