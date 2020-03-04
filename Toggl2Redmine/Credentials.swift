//
//  Credentials.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

struct Credentials {
    let redmineToken: String
    let togglToken: String
}

extension Credentials: Codable {
    enum CodingKeys: String, CodingKey {
        case redmineToken = "redmine"
        case togglToken = "toggl"
    }
}
