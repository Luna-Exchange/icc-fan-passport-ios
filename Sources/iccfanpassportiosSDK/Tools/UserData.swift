//
//  UserData.swift
//  TestPassport
//
//  Created by Computer on 5/27/24.
//

import Foundation

public struct UserData {
    public var token: String
    public var name: String
    public var email: String
    public init(token: String, name: String, email: String) {
        self.token = token
        self.name = name
        self.email = email
    }
}
