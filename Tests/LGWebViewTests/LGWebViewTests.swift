import XCTest
@testable import LGWebView

final class LGWebViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LGWebView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}