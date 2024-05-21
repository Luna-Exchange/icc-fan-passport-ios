//
//  iccfanSDK.swift
//  TestPassport
//
//  Created by Computer on 5/20/24.
//

import Foundation
import UIKit

public class iccfanSDK {
    static weak var sharedFanView: ICCWebView?

        public static func handle(url: URL) -> Bool {
            // Ensure the shared webview is not nil
            guard let  fanView = sharedFanView else {
                return false
            }
            
            // Pass the URL to the webview
            fanView.handleDeepLink(url)
            return true
        }
}
