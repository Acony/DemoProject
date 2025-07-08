import XCTest
import Testing
@testable import DemoProject

final class NetworkTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkManager = NetworkManager(session: mockURLSession)
    }
    
    override func tearDown() {
        networkManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    @Test func testSuccessfulRequest() async throws {
        // Given
        let expectedData = """
        {
            "id": 1,
            "name": "Test User"
        }
        """.data(using: .utf8)!
        
        mockURLSession.mockResponse = (expectedData, HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        
        // When
        let result = try await networkManager.request(endpoint: .users)
        
        // Then
        #expect(result == expectedData)
    }
    
    @Test func testFailedRequest() async throws {
        // Given
        mockURLSession.mockError = NSError(domain: "test", code: -1)
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint: .users)
            XCTFail("Expected error to be thrown")
        } catch {
            #expect(error is NetworkError)
        }
    }
}

// Mock URLSession for testing
class MockURLSession: URLSession {
    var mockResponse: (Data, URLResponse)?
    var mockError: Error?
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        guard let mockResponse = mockResponse else {
            throw NetworkError.invalidResponse
        }
        return mockResponse
    }
} 