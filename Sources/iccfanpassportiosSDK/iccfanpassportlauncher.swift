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
import SafariServices

public class ICCWebView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler,SFSafariViewControllerDelegate {
    public var webView: WKWebView!
    private var baseUrlString = "https://passport.icc-cricket.com/"
    private var activityIndicator: UIActivityIndicatorView!
    //private var loaderViewController: LoaderViewController?
    
    public var authToken: String
    public var name: String
    public var email: String
    public var publickey: String?
    public var accountid: String?
    public var initialEntryPoint: PassportEntryPoint
    public var navigateToICCAction: ((UIViewController) -> Void)?
    
    public init(authToken: String, name: String, email: String,publickey: String?,accountid: String?, initialEntryPoint: PassportEntryPoint) {
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
        //setupWebView()
        //startSDKOperations(entryPoint: initialEntryPoint) // Default entry point is home
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWebView()
        startSDKOperations(entryPoint: initialEntryPoint)
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
            navigateToICCAction?(<#UIViewController#>)
        }
    }
    
    public func startSDKOperations(entryPoint: PassportEntryPoint) {
        encryptAuthToken(authToken: authToken) { encryptedToken in
            DispatchQueue.main.async {
                var urlString: String
                
                if let accountId = self.accountid, let publickey = self.publickey, !accountId.isEmpty {
                    // If account id is not empty, construct URL with connect-wallet path
                    urlString = "\(self.baseUrlString)\(entryPoint)/connect-wallet?passport_access=\(encryptedToken)&account_id=\(accountId)&public_key=\(publickey)"
                } else {
                    // If account id is empty, construct URL with the specified path
                    urlString = "\(self.baseUrlString)\(entryPoint)?passport_access=\(encryptedToken)"
                }
                
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
        let url = URL(string: "https://passport-api.icc-cricket.com/auth/encode")!
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
        var path: String
        
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
    
    
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Determine if the URL should be opened in Safari
        if shouldOpenURLInSafari(url) {
            
            let urlmint = "https://mintbase-wallet-git-icc-theme-mintbase.vercel.app/?theme=icc?success_url=icc://mintbase.xyz"
            guard let safariURL = URL(string: urlmint) else {
                decisionHandler(.cancel)
                return
            }
            
            // Dismiss any presented view controllers, such as the Safari view controller
            if let presentingVC = self.presentingViewController {
                presentingVC.dismiss(animated: true, completion: {
                    UIApplication.shared.open(safariURL)
                })
            } else {
                UIApplication.shared.open(safariURL)
            }
            
            decisionHandler(.cancel)
            
        } else {
            // Continue loading the URL in the WKWebView
            decisionHandler(.allow)
        }
    }



        func shouldOpenURLInSafari(_ url: URL) -> Bool {
            // Check if the URL's host contains "wallet.mintbase.xyz"
            //return url.host?.contains("wallet.mintbase.xyz") ?? false
            return url.host?.contains("mintbase-wallet-git-icc-theme-mintbase.vercel.app") ?? false
        }
    
    // SFSafariViewControllerDelegate method to intercept URLs
    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            // Check if the URL is a deep link that should be handled by your app
            if URL.scheme == "my-deep-link" {
                // Handle the deep link here
                handleDeepLink(URL)
                // Dismiss the SFSafariViewController
                controller.dismiss(animated: true, completion: nil)
            }
        }
    
        func handleDeepLink(_ url: URL) {
                // Handle the deep link according to your app's logic
                // For example, navigate to a specific screen or perform an action
                    //print("Deep things")
            }
        
    
    
    
    
    
    
    
    
    // WKNavigationDelegate methods...
    
}
