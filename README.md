# iccfanpassportiosSDK Documentation

iccfanpassportiosSDK is a Swift package that provides a simple way to launch a web view in SwiftUI/UIKit applications.

## Overview

iccfanpassportiosSDK allows you to easily integrate a web view into your SwiftUI/UIKit views, enabling you to display web content within your application.

## Features

- Customize back and forward navigation gestures and link preview.
- Handle errors during web view navigation.
- Provide accessibility labels for improved accessibility.

- ## Adding MyWebViewLauncher to Your Project

### Swift Package Manager

To integrate iccfanpassportiosSDK into your Xcode project using Swift Package Manager, follow these steps:

1. In Xcode, select your project in the Project Navigator.
2. Go to the "Swift Packages" tab.
3. Click the "+" button and select "Add Package Dependency".
4. Enter the URL of the iccfanpassportiosSDK repository: `(https://github.com/Luna-Exchange/icc-fan-passport-ios.git)`
5. Click "Next", then select the version or branch you want to use.
6. Click "Next" and then "Finish" to add the package to your project.

```

# To integrate the WebViewController into a UIKit app, you can follow these steps:

1. Add the WebViewController Class to Your Project: Copy the WebViewController class implementation into your UIKit project.
2. Present or Push the WebViewController: Decide whether you want to present or push the WebViewController onto the navigation stack when you need to display web content. You can do this from any view controller in your app.
3. Instantiate and Display the WebViewController: Instantiate the WebViewController and present or push it from your existing view controller.

```
class MyViewController: UIViewController {

    @IBAction func showWebView(_ sender: UIButton) {
        // Instantiate ICCWebViewLaunch
        let authToken = "yourAuthToken"
        let name = "John Doe"
        let email = "john@example.com"
        
        let webViewLaunch = ICCWebView(authToken: authToken, name: name, email: email, username: username)
        
        // Present or push the ICCWebViewLaunch
        present(webViewLaunch, animated: true, completion: nil)
        /
    }
}
```
#
This documentation provides an overview of the SDK, usage instructions, configuration options, accessibility features, error handling, testing guidelines, and information on contributing and licensing. Adjust the content as needed to reflect the specifics of your SDK.
