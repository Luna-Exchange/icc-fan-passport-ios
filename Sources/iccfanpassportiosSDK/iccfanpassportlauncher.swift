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
    struct Logger {
        static var isEnabled: Bool { iccfanSDK.enableLogging }
        static func print(_ string: CustomStringConvertible) {
            if isEnabled {
                Swift.print(string)
            }
        }
    }
    private var urlList: [String] = []
    private var currentIndex: Int = 0
    
    public var webView: WKWebView!
    private var baseUrlString: String
    private var UrlStringMint: String
    private var UrlStringMinting: String
    private var UrlStringEncode: String
    private var deepLinkURLFantasy: String
    private var activityIndicator: UIActivityIndicatorView!
    private var backgroundImageView: UIImageView!
    
    public var authToken: String? { iccfanSDK.userData?.token }
    public var name: String? { iccfanSDK.userData?.name }
    public var email: String? { iccfanSDK.userData?.email }
    public var initialEntryPoint: PassportEntryPoint
   
    public typealias NavigateToICCAction = (UIViewController) -> Void  // Define callback type for navigation
    public var navigateToICCAction: NavigateToICCAction?  // Property to store navigation callback

    public typealias SignInWithIccCompletion = (Bool) -> Void  // Define callback type for sign-in
    public var signInWithIccCompletion: SignInWithIccCompletion?  // Property to store sign-in callback


    public init(initialEntryPoint: PassportEntryPoint, environment: Environment) {
        self.initialEntryPoint = initialEntryPoint
        switch environment {
        case .development:
            self.baseUrlString = "https://icc-fan-passport-staging.vercel.app/"
            self.UrlStringMint = "https://testnet.wallet.mintbase.xyz/connect?theme=icc&success_url=iccdev://mintbase.xyz"
            self.UrlStringMinting = "https://testnet.wallet.mintbase.xyz/sign-transaction?theme=icc&transactions_data=${encodedTransaction}&callback_url=iccdev://mintbase.xyz"
            self.UrlStringEncode = "https://icc-fan-passport-stg-api.insomnialabs.xyz/auth/encode"
            self.deepLinkURLFantasy = "iccdev://react-fe-en.icc-dev.deltatre.digital/fantasy-game"
        case .production:
            self.baseUrlString = "https://fanpassport.icc-cricket.com/"
            self.UrlStringMint = "https://wallet.mintbase.xyz/connect?theme=icc?success_url=icc://mintbase.xyz"
            self.UrlStringMinting = "https://wallet.mintbase.xyz/sign-transaction?theme=icc&transactions_data=${encodedTransaction}&callback_url=iccdev://mintbase.xyz"
            self.UrlStringEncode = "https://passport-api.icc-cricket.com/"
            self.deepLinkURLFantasy = "icc://www.icc-cricket.com/fantasy-game"
        }
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshed), name: TokenManager.tokenRefreshedNotification, object: nil)

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
        setupBackgroundImageView()
        setupActivityIndicator()
//        if let authToken = self.authToken, !authToken.isEmpty {
//            startSDKOperations(entryPoint: initialEntryPoint)
//        } else {
//            loadURL(baseUrlString)
//        }
        if let authToken = TokenManager.shared.getAccessToken(), !authToken.isEmpty {
            startSDKOperations(entryPoint: initialEntryPoint)
        } else {
            loadURL(baseUrlString)
        }
    }
    
    func update(userData: UserData?) {
        startSDKOperations(entryPoint: self.initialEntryPoint)
    }
    
    @objc private func tokenRefreshed() {
            Logger.print("Token refreshed")
            if let authToken = TokenManager.shared.getAccessToken(), !authToken.isEmpty {
                startSDKOperations(entryPoint: initialEntryPoint)
            } else {
                loadURL(baseUrlString)
            }
        }
    
    func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
                
        // Add script message handler for 'navigateToIcc'
        webView.configuration.userContentController.add(self, name: "navigateToIcc")
        webView.configuration.userContentController.add(self, name: "goToFantasy")
        webView.configuration.userContentController.add(self, name: "dddd")
        // Set up Auto Layout constraints to make the webView full screen
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupBackgroundImageView() {
        // Initialize the background image view
        backgroundImageView = UIImageView(image: UIImage(named: "loadingpage.png"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // Set up Auto Layout constraints to make the background image view full screen
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Center the activity indicator in the view
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Inject JavaScript to handle multiple events
        let script = """
            window.addEventListener('navigate-to-icc', function() {
                window.webkit.messageHandlers.navigateToIcc.postMessage(null);
            });
            window.addEventListener('go-to-fantasy', function() {
                  window.webkit.messageHandlers.goToFantasy.postMessage(null);
                });
            window.addEventListener('sign-in-with-icc', function() {
                  window.webkit.messageHandlers.signInWithIcc.postMessage(null);
                });
        """

        webView.evaluateJavaScript(script, completionHandler: nil)

        activityIndicator.stopAnimating()
        backgroundImageView.isHidden = true // Hide the background image when loading finishes
        
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        backgroundImageView.isHidden = false // Show the background image when loading starts
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        backgroundImageView.isHidden = true // Hide the background image if loading fails
    }


    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "navigateToIcc":
            Logger.print("Received 'navigate-to-icc' event")
            navigateToICCAction?(self)
        case "goToFantasy":
            Logger.print("Received 'go-to-fantasy' event")
            // Call your callback action for event-name-1 here
            openDeepLink(urlString: deepLinkURLFantasy)
            Logger.print("Fantasy")
        case "signInWithIcc":
            Logger.print("Received 'sign-in-with-icc' event")
            // Call your callback action for event-name-2 here
            signInWithIccCompletion?(true)
        default:
            Logger.print("Received unknown event: \(message.name)")
        }
    }
    
    
    private func openDeepLink(urlString: String) {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    
    func startSDKOperations(entryPoint: PassportEntryPoint, accountid: String? = nil, publickey: String? = nil) {
        
        if let accountId = accountid, let publicKey = publickey, !accountId.isEmpty {
            let userDefaults = UserDefaults.standard
            if let tokenmintString = userDefaults.string(forKey: "tokenmint") {
                let urlString2 = "\(self.baseUrlString)\(entryPoint)/connect-wallet?account_id=\(accountId)&public_key=\(publicKey)"
                self.loadURL(urlString2)
                Logger.print(urlString2)
                
            } else {
                // Handle the case where "tokenmint" is not found in UserDefaults
                Logger.print("Missing tokenmint! Cannot construct URL.")
            }
            
            
        }else{
            encryptAuthToken(authToken: authToken!) { encryptedToken in
                DispatchQueue.main.async {
                    
                    // If account id is empty, construct URL with the specified path
                    let urlString = "\(self.baseUrlString)\(entryPoint)?passport_access=\(encryptedToken)"
                    
                    self.loadURL(urlString)
                    
                }
            }
        }
            
    
    }
    
    
   
    
    private func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func encryptAuthToken(authToken: String, completion: @escaping (String) -> Void) {
        // Prepare the request
        guard let url = URL(string: UrlStringEncode) else {
            Logger.print("Invalid URL string: \(UrlStringEncode)")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the request body
        let requestBody: [String: String] = [
            "authToken": authToken,
            "name": name!,
            "email": email!
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            Logger.print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                Logger.print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let statusCode = json["statusCode"] as? Int, statusCode == 200,
                   let responseData = json["data"] as? [String: Any],
                   let encryptedToken = responseData["token"] as? String {
                    // Call completion handler with encrypted token
                    completion(encryptedToken)
                } else {
                    Logger.print("Error: Unable to parse response or token not found")
                }
            } catch {
                Logger.print("JSON parsing error: \(error.localizedDescription)")
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
            openSafariViewController(with: safariURL)
            
            decisionHandler(.cancel)
        } else {
            // Continue loading the URL in the WKWebView
            guard let safariURL = URL(string: UrlStringMinting) else {
                decisionHandler(.cancel)
                return
            }
            openSafariViewController(with: safariURL)
            decisionHandler(.allow)
        }
    }

    func openSafariViewController(with url: URL) {
        // Dismiss any presented view controllers, such as the Safari view controller
        if let presentingVC = self.presentedViewController {
            presentingVC.dismiss(animated: true, completion: {
                UIApplication.shared.open(url)
            })
        } else {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true)
        }
    }

    func shouldOpenURLInSafari(_ url: URL) -> Bool {
        // Define all conditions that should lead to a Mintbase site
        let mintbaseHosts = ["/connect"]
        let mintbasePaths = ["/sign-transaction"]

        for host in mintbasePaths {
            if url.path.contains(host){
                return true
            }
        }

        for path in mintbasePaths {
            if url.path.contains(path) {
                return false
            }
        }
        
        return false
    }
    
    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        // Check if the URL is a deep link that should be handled by your app
        if URL.scheme == "iccdev" {
            
            handleDeepLink(URL)
            Logger.print("Safari Controller Did close")
            Logger.print(URL)
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func retrieveEncryptedToken() -> String? {
      let defaults = UserDefaults.standard
      let encryptedToken = defaults.string(forKey: "encryptedToken")
      return encryptedToken
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
                if let extractedPublicKey = publicKey {
                      publicKey = encodePublicKey(extractedPublicKey)  // Encode the colon back
                  }
                
                // Debugging output
                Logger.print("Account ID: \(accountId ?? "N/A")")
                Logger.print("Public Key: \(publicKey ?? "N/A")")
                
                // Inject JavaScript to handle the deeplink within the webview
                let jsCommand = "handleDeepLink('\(url.absoluteString)')"
                Logger.print(url.absoluteString)
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
    
    func encodePublicKey(_ publicKey: String) -> String {
      return publicKey.replacingOccurrences(of: "%3A", with: "")
    }

    func presentAndHandleCallbacks(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(self, animated: animated, completion: completion)  // Present the ICCWebView
      }
}

