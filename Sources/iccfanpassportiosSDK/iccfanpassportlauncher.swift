//
//  Iccfan.swift
//  TestPassport
//
//  Created by Computer on 5/20/24.
//

import Foundation
import UIKit
import WebKit
import SafariServices

public class ICCWebView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
    public var webView: WKWebView!
    private var baseUrlString: String
    private var UrlStringMint: String
    private var UrlStringEncode: String
    private var activityIndicator: UIActivityIndicatorView!
    
    public var authToken: String
    public var name: String
    public var email: String
    public var initialEntryPoint: PassportEntryPoint
    public var navigateToICCAction: ((UIViewController) -> Void)? // Callback closure

    public init(authToken: String, name: String, email: String, initialEntryPoint: PassportEntryPoint, environment: Environment) {
        self.authToken = authToken
        self.name = name
        self.email = email
        self.initialEntryPoint = initialEntryPoint
        switch environment {
        case .development:
            self.baseUrlString = "https://icc-fan-passport-staging.vercel.app/"
            self.UrlStringMint = "https://wallet.mintbase.xyz/connect?theme=icc&success_url=iccdev://mintbase.xyz"
            self.UrlStringEncode = "https://icc-fan-passport-stg-api.insomnialabs.xyz/auth/encode"
        case .production:
            self.baseUrlString = "https://fanpassport.icc-cricket.com/"
            self.UrlStringMint = "https://wallet.mintbase.xyz/connect?theme=icc?success_url=icc://mintbase.xyz"
            self.UrlStringEncode = "https://passport-api.icc-cricket.com/"
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Setup and operations are done in viewWillAppear to ensure they run each time the view appears
        iccfanSDK.sharedFanView = self // Retain the reference to the shared instance
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
            navigateToICCAction?(self)
        }
    }
    
    public func startSDKOperations(entryPoint: PassportEntryPoint, accountid: String? = nil, publickey: String? = nil) {
        encryptAuthToken(authToken: authToken) { encryptedToken in
            DispatchQueue.main.async {
                var urlString: String
                
                if let accountId = accountid, let publicKey = publickey, !accountId.isEmpty {
                    // If account id is not empty, construct URL with connect-wallet path
                    urlString = "\(self.baseUrlString)\(entryPoint)/connect-wallet?passport_access=\(encryptedToken)&account_id=\(accountId)&public_key=\(publicKey)"
                    print(urlString)
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
        let url = URL(string: UrlStringEncode)!
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
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Determine if the URL should be opened in Safari
        if shouldOpenURLInSafari(url) {
            guard let safariURL = URL(string: UrlStringMint) else {
                decisionHandler(.cancel)
                return
            }
            
            // Dismiss any presented view controllers, such as the Safari view controller
            if let presentingVC = self.presentedViewController {
                presentingVC.dismiss(animated: true, completion: {
                    UIApplication.shared.open(safariURL)
                })
            } else {
                //UIApplication.shared.open(safariURL)
                let safari = SFSafariViewController(url: safariURL)
                safari.delegate = self
                self.present(safari, animated: true)
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
        return url.host?.contains("mintbase") ?? false
    }
    
    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        // Check if the URL is a deep link that should be handled by your app
        if URL.scheme == "iccdev" {
            
            handleDeepLink(URL)
            print("Safari Controller Did close")
            print(URL)
            controller.dismiss(animated: true, completion: nil)
        }
    }

    func handleDeepLink(_ url: URL) {
        // Check if the URL contains "mintbase.xyz"
        if url.host?.contains("mintbase.xyz") == true {
            // Use URLComponents to parse the URL and extract the query parameters
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var accountId: String?
                var publicKey: String?
                
                // Loop through the query items to find account_id and public_key
                if let queryItems = urlComponents.queryItems {
                    for queryItem in queryItems {
                        if queryItem.name == "account_id" {
                            accountId = queryItem.value
                        } else if queryItem.name == "public_key" {
                            publicKey = queryItem.value
                        }
                    }
                }
                
                // Debugging output
                print("Account ID: \(accountId ?? "N/A")")
                print("Public Key: \(publicKey ?? "N/A")")
                
                // Inject JavaScript to handle the deeplink within the webview
                let jsCommand = "handleDeepLink('\(url.absoluteString)')"
                print(jsCommand)
                webView.evaluateJavaScript(jsCommand, completionHandler: nil)
                
                // Restart SDK operations with the extracted account_id and public_key
                if let accountId = accountId, let publicKey = publicKey {
                    startSDKOperations(entryPoint: .onboarding, accountid: accountId, publickey: publicKey)
                }
            }
        }
        
        // Dismiss any presented view controllers, such as a Safari view controller
        self.presentedViewController?.dismiss(animated: true)
    }


    
//    public func restartSDKAgain(entryPoint: PassportEntryPoint, accountid: String, publickey: String ) {
//            encryptAuthToken(authToken: authToken) { encryptedToken in
//                DispatchQueue.main.async {
//                    var urlString: String
//                    
//                        urlString = "\(self.baseUrlString)\(entryPoint)/connect-wallet?passport_access=\(encryptedToken)&account_id=\(accountid)&public_key=\(publickey)"
//                   
//                    
//                    if let url = URL(string: urlString) {
//                        self.webView.load(URLRequest(url: url))
//                    } else {
//                        print("Error: Invalid URL")
//                    }
//                }
//            }
//        }
}
