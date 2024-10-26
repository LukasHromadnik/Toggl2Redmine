struct Configuration {
    let redmineToken: String
    let togglToken: String
    let nonGroupingTickets: [Int]?
}

extension Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case redmineToken = "redmine"
        case togglToken = "toggl"
        case nonGroupingTickets = "grouping-disabled"
    }
}
