# iccfanpassportiosSDK Documentation

ICCWebViewLauncher is a Swift package that provides a simple way to launch a web view in SwiftUI/UIKit applications.

## Overview

ICCWebViewLauncher allows you to easily integrate a web view into your SwiftUI/UIKit views, enabling you to display web content within your application.

## Features

- Launch a web view with a specified URL(https://starter.mintbase.xyz/) for now.
- Customize back and forward navigation gestures and link preview.
- Handle errors during web view navigation.
- Provide accessibility labels for improved accessibility.

- ## Adding MyWebViewLauncher to Your Project

### Swift Package Manager

To integrate MyWebViewLauncher into your Xcode project using Swift Package Manager, follow these steps:

1. In Xcode, select your project in the Project Navigator.
2. Go to the "Swift Packages" tab.
3. Click the "+" button and select "Add Package Dependency".
4. Enter the URL of the ICCWebViewLauncher repository: `(https://github.com/Luna-Exchange/icc-fan-passport-ios.git)`
5. Click "Next", then select the version or branch you want to use.
6. Click "Next" and then "Finish" to add the package to your project.

### Manual Installation

If you prefer not to use Swift Package Manager, you can manually add the MyWebViewLauncher files to your project:

1. Clone or download the ICCWebViewLauncher repository from [GitHub](https://github.com/Luna-Exchange/icc-fan-passport-ios.git).
2. Copy the `iccfanpassportiosSDK.swift` file into your Xcode project.
3. Make sure to add the necessary imports for `UIKit` and `WebKit` in any files where you use the `WebViewController`.


## Usage

#To use ICCWebViewLauncher in your SwiftUI view, follow these steps:

1. Import the ICCWebViewLauncher module.
2. Call the `launchWebView()` method with the desired URL.

```swift
For SwiftUI

import SwiftUI
import iccfanpassSDKSwiftUI

struct ContentView: View {
    var body: some View {
        MyWebViewLauncher.launchWebView(url: URL)
    }
}
```

# To integrate the WebViewController into a UIKit app, you can follow these steps:

1. Add the WebViewController Class to Your Project: Copy the WebViewController class implementation into your UIKit project.
2. Present or Push the WebViewController: Decide whether you want to present or push the WebViewController onto the navigation stack when you need to display web content. You can do this from any view controller in your app.
3. Instantiate and Display the WebViewController: Instantiate the WebViewController and present or push it from your existing view controller.

```
import UIKit

class MyViewController: UIViewController {

    @IBAction func showWebView(_ sender: UIButton) {
        // Instantiate WebViewController
        let webViewController = WebViewController()
        
        // Present or push the WebViewController
        // Example: Present modally
        present(webViewController, animated: true, completion: nil)
        
        // Example: Push onto navigation stack
        // navigationController?.pushViewController(webViewController, animated: true)
    }
}
```
#
This documentation provides an overview of the SDK, usage instructions, configuration options, accessibility features, error handling, testing guidelines, and information on contributing and licensing. Adjust the content as needed to reflect the specifics of your SDK.
