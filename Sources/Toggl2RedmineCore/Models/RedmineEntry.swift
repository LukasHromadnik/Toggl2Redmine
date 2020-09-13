//
//  RedmineEntry.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

public class RedmineEntry {
    public let issueID: Int
    public var duration: Int
    public var comments: [String]
    public let spentOn: String

    public init(issueID: Int, duration: Int = 0, comments: [String] = [], spentOn: String) {
        self.issueID = issueID
        self.duration = duration
        self.comments = comments
        self.spentOn = spentOn
    }

    public func addComment(_ comment: String) {
        guard comments.contains(comment) == false else { return }
        comments.append(comment)
    }
}

public extension RedmineEntry {
    var hours: Double {
        Double(duration) / 3600
    }

    var formattedComments: String {
        comments.isEmpty ? "" : comments.joined(separator: ", ")
    }
}

extension RedmineEntry: CustomStringConvertible {
    public var description: String {
        "\(issueID): \(hours) (\(duration) m), \(formattedComments), \(spentOn)"
    }
}
