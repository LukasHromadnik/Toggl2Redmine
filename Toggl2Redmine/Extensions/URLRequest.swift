//
//  URLRequest.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

extension URLRequest {

    /// Adds basic authorization header to the request
    ///
    /// - Parameters:
    ///   - username: Given username
    ///   - password: Given password
    mutating func addBasicAuth(username: String, password: String) {
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    }

    mutating func setJSONBody(_ body: [String: Any]) {
        httpBody = try! JSONSerialization.data(withJSONObject: body)
    }

}
