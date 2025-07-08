import XCTest
import Testing
@testable import DemoProject

// MARK: - Test Data Factory
enum TestData {
    static func createMockUser(id: Int = 1, name: String = "Test User") -> User {
        return User(id: id, name: name)
    }
    
    static func createMockData() -> Data {
        return """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!
    }
}

// MARK: - XCTestCase Extensions
extension XCTestCase {
    func wait(for duration: TimeInterval) {
        let expectation = expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: duration + 1)
    }
}

// MARK: - Mock Network Response
struct MockNetworkResponse {
    static func success(data: Data) -> (Data, HTTPURLResponse) {
        return (data, HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!)
    }
    
    static func failure(statusCode: Int) -> (Data, HTTPURLResponse) {
        return (Data(), HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!)
    }
}

// MARK: - Test Assertions
func assertThrowsError<T>(_ expression: @autoclosure () throws -> T, errorType: Error.Type, message: String = "") {
    XCTAssertThrowsError(try expression(), message) { error in
        XCTAssertTrue(error is NetworkError, "Error should be of type \(errorType)")
    }
} 