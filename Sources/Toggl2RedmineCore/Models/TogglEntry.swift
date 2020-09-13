//
//  TogglEntry.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

public let kSynchronizedTag = "Synchronized"

public struct TogglEntry {
    public let id: Int
    public let description: String
    public let start: Date
    public let duration: Int
    public let tags: [String]
}

extension TogglEntry: Codable {
    public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! container.decode(Int.self, forKey: .id)
        let description = try! container.decodeIfPresent(String.self, forKey: .description)
        self.description = description ?? ""
        start = try! container.decode(Date.self, forKey: .start)
        duration = try! container.decode(Int.self, forKey: .duration)
        let tags = try! container.decodeIfPresent([String].self, forKey: .tags)
        self.tags = tags ?? []
    }
}

public extension TogglEntry {
    var issueID: Int? {
        let pattern = "#([0-9]+):"
        guard let range = description.range(of: pattern, options: .regularExpression) else { return nil }
        return Int(description[range].dropLast().dropFirst())
    }

    var comment: String? {
        let pattern = "\\[.*\\]"
        guard let range = description.range(of: pattern, options: .regularExpression) else { return nil }
        return String(description[range].dropLast().dropFirst())
    }

    var isValid: Bool {
        issueID != nil && tags.contains(kSynchronizedTag) == false && duration > 0
    }
}