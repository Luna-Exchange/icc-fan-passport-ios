# iccfanpassportiosSDK Documentation
## iccfanpassportiosSDK 1.0.6

### Overview

The `iccfanpassportiosSDK` SDK provides a way to integrate a web-based ICC Fan Passport experience into your iOS app. It includes a customizable `WKWebView` and handles deep links, authentication, and navigation to ICC-related content.

### Features

- Display ICC Fan Passport web content within your app
- Handle deep links to navigate back to the app
- Securely encrypt and pass authentication tokens
- Customizable navigation actions

### Installation

To use `ICCWebView` in your project, include the `iccfanpassportlauncher.swift` file in your Xcode project.

### Initialization

To initialize `ICCWebView`, create an instance and configure it with the necessary parameters.

```swift
import UIKit

let iccWebView = ICCWebView(
    authToken: "yourAuthToken",
    name: "userName",
    email: "userEmail",
    publickey: "userPublicKey",
    accountid: "userAccountID",
    initialEntryPoint: .onboarding
)
```

### Parameters

- `authToken`: The authentication token for the user.
- `name`: The name of the user.
- `email`: The email of the user.
- `publickey`: The public key of the user (optional).
- `accountid`: The account ID of the user (optional).
- `initialEntryPoint`: The initial entry point for the passport (`.onboarding`, `.profile`, `.createavatar`, `.challenge`, `.rewards`).

### Usage

Add the `ICCWebView` to your view hierarchy and set up the navigation action.

```swift
import UIKit

class YourViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iccWebView = ICCWebView(
            authToken: "yourAuthToken",
            name: "userName",
            email: "userEmail",
            publickey: "userPublicKey",
            accountid: "userAccountID",
            initialEntryPoint: .onboarding
        )
        
        // Set up navigation action
        iccWebView.navigateToICCAction = { [weak self] viewController in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        // Add ICCWebView as a child view controller
        addChild(iccWebView)
        view.addSubview(iccWebView.view)
        iccWebView.didMove(toParent: self)
    }
}
```

## Handling Deep Links

ICCWebView can handle deep links that navigate back to your app. When the deep link happens after wallet creation, it comes with parameters called public_key and accountid, such as:

perl
Copy code
icc://mintbase.xyz?account_id=korva-nhgor.near&public_key=ed25519%3A2n8HRsRNaaNm5RguWupo72shEwdqge67ESCpgyedTMhR
Note that icc is the schema in the SDK. You will need to handle storing the public key and account ID in your app delegate and navigate to the preferred view controller.

## Customizing Web Content

To start operations with a specific entry point, use the `startSDKOperations` method. The URL is constructed based on the provided entry point and authentication token.

```swift
iccWebView.startSDKOperations(entryPoint: .profile)
```

### Example

Here’s a complete example of using `ICCWebView` in a view controller:

```swift
import UIKit

class YourViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iccWebView = ICCWebView(
            authToken: "yourAuthToken",
            name: "userName",
            email: "userEmail",
            publickey: "userPublicKey",
            accountid: "userAccountID",
            initialEntryPoint: .onboarding
        )
        
        iccWebView.navigateToICCAction = { [weak self] viewController in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        addChild(iccWebView)
        view.addSubview(iccWebView.view)
        iccWebView.didMove(toParent: self)
    }
    
    func handleDeepLink(_ url: URL) {
        print("Received deep link: \(url)")
    }
}
```

### Notes

- Ensure to configure `navigateToICCAction` to handle navigation within your app.

This documentation provides a concise guide to integrating and using the `ICCWebView` SDK within your iOS app. For any advanced customizations or additional features, refer to the source code and extend the functionality as needed.
