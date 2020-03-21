//
//  Credentials.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

public struct Credentials {
    public let redmineToken: String
    public let togglToken: String
}

extension Credentials: Codable {
    enum CodingKeys: String, CodingKey {
        case redmineToken = "redmine"
        case togglToken = "toggl"
    }
}
