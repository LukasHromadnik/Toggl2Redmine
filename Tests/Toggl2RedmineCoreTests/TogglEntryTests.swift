import Toggl2RedmineCore
import XCTest

final class TogglEntryTests: XCTestCase {
    func test_isValid_isCaseInsensitive() {
        XCTAssertFalse(TogglEntry.test(tags: ["SYNCHRONIZED"]).isValid)
        XCTAssertFalse(TogglEntry.test(tags: ["Synchronized"]).isValid)
        XCTAssertFalse(TogglEntry.test(tags: ["synchronized"]).isValid)
    }
    
    static var allTests = [
        ("test_isValid_isCaseInsensitive", test_isValid_isCaseInsensitive),
    ]
}
