//
//  File.swift
//  
//
//  Created by Computer on 4/25/24.
//

import Foundation
import UIKit

class IccAuthManager {
    // Function to trigger SDK operations
    func triggerSDK(authToken: String, name: String, email: String, username: String, completion: @escaping (String) -> Void) {
        // Collect user information
        let userInfo = [
            "authToken": authToken,
            "name": name,
            "email": email,
            "username": username
        ]
        
        // Call function to encrypt the Auth Token
        encryptAuthToken(authToken: authToken, userInfo: userInfo) { encryptedToken in
            completion(encryptedToken)
        }
    }
    
    // Function to encrypt the Auth Token
    private func encryptAuthToken(authToken: String, userInfo: [String: String], completion: @escaping (String) -> Void) {
        // Prepare the request
        let url = URL(string: "http://icc-fan-passport-stg-env.eba-tptrhhya.us-east-1.elasticbeanstalk.com/auth/encode")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the request body
        let requestBody: [String: String] = [
            "authToken": authToken
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
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let encryptedToken = json["token"] {
                // Call completion handler with encrypted token
                completion(encryptedToken)
            } else {
                print("Error: Unable to parse response")
            }
        }
        task.resume()
    }
}
