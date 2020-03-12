//
//  RedmineEntry.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

class RedmineEntry {
    let issueID: Int
    var duration: Int
    var comments: [String]
    let spentOn: String

    init(issueID: Int, duration: Int = 0, comments: [String] = [], spentOn: String) {
        self.issueID = issueID
        self.duration = duration
        self.comments = comments
        self.spentOn = spentOn
    }

    func addComment(_ comment: String) {
        guard comments.contains(comment) == false else { return }
        comments.append(comment)
    }
}

extension RedmineEntry {
    var hours: Double {
        Double(duration) / 3600
    }

    var formattedComments: String {
        comments.isEmpty ? "" : comments.joined(separator: ", ")
    }
}

extension RedmineEntry: CustomStringConvertible {
    var description: String {
        "\(issueID): \(hours) (\(duration) m), \(formattedComments), \(spentOn)"
    }
}
