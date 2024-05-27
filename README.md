# iccfanpassportiosSDK Documentation
## iccfanpassportiosSDK 1.0.8

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
    initialEntryPoint: .onboarding
    Environment = Environment.production
)
```

### Parameters

- `authToken`: The authentication token for the user.
- `name`: The name of the user.
- `email`: The email of the user.
- `initialEntryPoint`: The initial entry point for the passport (`.onboarding`, `.profile`, `.createavatar`, `.challenge`, `.rewards`).
- `initialEntryPoint`: The initial environment for the passport (`.prodution`, `.developement`).

### Usage

Add the `ICCWebView` to your view hierarchy and set up the navigation action.

```swift
import UIKit

class YourViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iccWebView = ICCWebView(
            authToken: "yourAuthToken",
              let name = "name"
        let email = "email address"
        let initialEntryPoint = PassportEntryPoint.challenges // Replace with actual entry point
        let environment = Environment.production // or .development
        
        let iccFanView = ICCFan(authToken: authToken, name: name, email: email, initialEntryPoint: initialEntryPoint, environment: environment)
        
        
        // Set up the completion handlers
        iccWebView.signInWithIccCompletion = { success in
            if success {
                print("Sign-in with ICC was successful")
                // Handle success, e.g., dismiss the ICCWebView or navigate to another screen
            } else {
                print("Sign-in with ICC failed")
                // Handle failure
            }
        }

        iccWebView.navigateToICCAction = { viewController in
            print("Navigate to ICC action triggered")
            // Handle navigation to ICC action, e.g., present another view controller
        }
        
    }
}
```

## Handling Deep Links

ICCWebView can handle deep links that navigate back to your app. When the deep link happens after wallet creation, it comes with parameters called public_key and accountid, such as:

So add this to your appdelegate:
            iccfanSDK.handle(url: URL)
            
            ##Example
                func application(_ app: UIApplication, open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]
                ) -> Bool {
            
                    return iccfanSDK.handle(url: url)
                }


## Customizing Web Content

To start operations with a specific entry point, use the `startSDKOperations` method. The URL is constructed based on the provided entry point and authentication token.

```swift
iccWebView.startSDKOperations(entryPoint: .profile)
```



### Notes

- Ensure to configure `navigateToICCAction` to handle navigation within your app.

This documentation provides a concise guide to integrating and using the `ICCWebView` SDK within your iOS app. For any advanced customizations or additional features, refer to the source code and extend the functionality as needed.
