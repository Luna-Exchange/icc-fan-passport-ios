//
//  File.swift
//  
//
//  Created by Computer on 5/6/24.
//

import Foundation
import UIKit

class LoaderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5) // Semi-transparent black background
        if #available(iOS 13.0, *) {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
        } else {
            // Fallback on earlier versions
        }
        
    }
}
