//
//  TokenManager.swift
//  TestPassport
//
//  Created by Computer on 5/27/24.
//

import Foundation

class TokenManager {
    
    // Singleton instance
    static let shared = TokenManager()
    
    static let tokenRefreshedNotification = Notification.Name("TokenManagerTokenRefreshed")
    
    private init() {}
    
    // Properties to store tokens
    private var refreshToken: String?
    private var accessToken: String?
    
    // Method to set tokens
    public func setTokens(refreshToken: String, accessToken: String) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        
        // Post notification when tokens are updated
        NotificationCenter.default.post(name: TokenManager.tokenRefreshedNotification, object: nil)
    }
    
    // Method to get the refresh token
    public func getRefreshToken() -> String? {
        return refreshToken
    }
    
    // Method to get the access token
    public func getAccessToken() -> String? {
        return accessToken
    }
}
