//
//  TogglEntry.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

let kSynchronizedTag = "Synchronized"

struct TogglEntry {
    let id: Int
    let description: String
    let start: Date
    let duration: Int
    let tags: [String]
}

extension TogglEntry: Codable {
    init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        id = try! container.decode(Int.self, forKey: .id)
        description = try! container.decode(String.self, forKey: .description)
        start = try! container.decode(Date.self, forKey: .start)
        duration = try! container.decode(Int.self, forKey: .duration)
        let tags = try! container.decodeIfPresent([String].self, forKey: .tags)
        self.tags = tags ?? []
    }
}

extension TogglEntry {
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
