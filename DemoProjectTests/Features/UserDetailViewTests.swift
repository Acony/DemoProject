import XCTest
import SwiftUI
import Testing
@testable import DemoProject

final class UserDetailViewTests: XCTestCase {
    var viewModel: GithubUserDetailViewModel!
    var mockNetworkService: MockNetworkService!
    var testUser: GitHubUser!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = GithubUserDetailViewModel(networkService: mockNetworkService)
        testUser = GitHubUser(
            id: 1,
            login: "testuser",
            avatarUrl: "https://example.com/avatar.jpg",
            htmlUrl: "https://github.com/testuser"
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        testUser = nil
        super.tearDown()
    }
    
    // MARK: - ViewModel Tests
    
    @Test func testInitialState() {
        #expect(viewModel.userDetail == nil)
        #expect(!viewModel.isLoading)
    }
    
    @Test func testFetchUserDetailSuccess() async {
        // Given
        let mockUserDetail = GitHubUserDetail(
            login: "testuser",
            avatarUrl: "https://example.com/avatar.jpg",
            htmlUrl: "https://github.com/testuser",
            name: "Test User",
            location: "Test Location",
            followers: 100,
            following: 50
        )
        mockNetworkService.mockUserDetail = mockUserDetail
        
        // When
        await viewModel.fetchUserDetail(from: "testuser")
        
        // Then
        #expect(viewModel.userDetail?.login == "testuser")
        #expect(viewModel.userDetail?.location == "Test Location")
        #expect(viewModel.userDetail?.followers == 100)
        #expect(viewModel.userDetail?.following == 50)
    }
    
    @Test func testFetchUserDetailFailure() async {
        // Given
        mockNetworkService.shouldFail = true
        
        // When
        await viewModel.fetchUserDetail(from: "testuser")
        
        // Then
        #expect(viewModel.userDetail == nil)
        #expect(!viewModel.isLoading)
    }
    
    // MARK: - View Tests
    
    @Test func testUserDetailViewInitialization() {
        // Given
        let view = UserDetailView(user: testUser)
        
        // Then
        #expect(view.user.id == testUser.id)
        #expect(view.user.login == testUser.login)
    }
    
    @Test func testComputedProperties() {
        // Given
        let view = UserDetailView(user: testUser)
        let mockUserDetail = GitHubUserDetail(
            login: "testuser",
            avatarUrl: "https://example.com/new-avatar.jpg",
            htmlUrl: "https://github.com/testuser",
            name: "Test User",
            location: "New Location",
            followers: 200,
            following: 100
        )
        
        // When
        view.viewModel.userDetail = mockUserDetail
        
        // Then
        #expect(view.username == "testuser")
        #expect(view.location == "New Location")
        #expect(view.followers == 200)
        #expect(view.following == 100)
        #expect(view.avatarUrl?.absoluteString == "https://example.com/new-avatar.jpg")
    }
    
    @Test func testUserInfoCard() {
        // Given
        let username = "testuser"
        let location = "Test Location"
        let avatarUrl = URL(string: "https://example.com/avatar.jpg")
        
        // When
        let userInfoCard = UserInfoCard(
            username: username,
            avatarUrl: avatarUrl,
            location: location
        )
        
        // Then
        let mirror = Mirror(reflecting: userInfoCard.body)
        let hasUsername = mirror.children.contains { child in
            if let text = child.value as? Text {
                return text.verbatim == username
            }
            return false
        }
        #expect(hasUsername)
    }
    
    @Test func testUserStatsView() {
        // Given
        let followers = 100
        let following = 50
        
        // When
        let statsView = UserStatsView(followers: followers, following: following)
        
        // Then
        let mirror = Mirror(reflecting: statsView.body)
        let hasStats = mirror.children.contains { child in
            if let text = child.value as? Text {
                return text.verbatim == "\(followers)+" || text.verbatim == "\(following)+"
            }
            return false
        }
        #expect(hasStats)
    }
}

// MARK: - Mock Network Service Extension

extension MockNetworkService {
    var mockUserDetail: GitHubUserDetail?
    
    func fetchUserDetail(username: String) async throws -> GitHubUserDetail {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        guard let userDetail = mockUserDetail else {
            throw NetworkError.invalidResponse
        }
        return userDetail
    }
} 