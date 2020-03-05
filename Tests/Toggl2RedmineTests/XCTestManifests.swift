import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Toggl2RedmineTests.allTests),
    ]
}
#endif
