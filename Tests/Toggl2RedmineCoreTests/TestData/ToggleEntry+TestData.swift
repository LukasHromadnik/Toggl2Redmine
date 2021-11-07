import Foundation
import Toggl2RedmineCore

extension TogglEntry {
    static func test(
        id: Int = 1,
        description: String = "#1: Issue",
        start: Date = .init(),
        duration: Int = 60,
        tags: [String] = []
    ) -> TogglEntry {
        .init(
            id: id,
            description: description,
            start: start,
            duration: duration,
            tags: tags
        )
    }
}
