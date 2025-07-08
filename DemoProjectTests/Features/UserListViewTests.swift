import XCTest
import SwiftUI
import Testing
@testable import DemoProject

final class UserListViewTests: XCTestCase {
    var viewModel: GithubUserViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = GithubUserViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - ViewModel Tests
    
    @Test func testInitialState() {
        #expect(viewModel.users.isEmpty)
        #expect(!viewModel.isLoading)
    }
    
    @Test func testLoadMoreSuccess() async {
        // Given
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: "url1", htmlUrl: "html1"),
            GitHubUser(id: 2, login: "user2", avatarUrl: "url2", htmlUrl: "html2")
        ]
        mockNetworkService.mockUsers = mockUsers
        
        // When
        await viewModel.loadMore()
        
        // Then
        #expect(viewModel.users.count == 2)
        #expect(viewModel.users[0].login == "user1")
        #expect(viewModel.users[1].login == "user2")
    }
    
    @Test func testLoadMoreFailure() async {
        // Given
        mockNetworkService.shouldFail = true
        
        // When
        await viewModel.loadMore()
        
        // Then
        #expect(viewModel.users.isEmpty)
        #expect(!viewModel.isLoading)
    }
    
    @Test func testPagination() async {
        // Given
        let firstPageUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: "url1", htmlUrl: "html1")
        ]
        let secondPageUsers = [
            GitHubUser(id: 2, login: "user2", avatarUrl: "url2", htmlUrl: "html2")
        ]
        mockNetworkService.mockUsers = firstPageUsers
        
        // When - First page
        await viewModel.loadMore()
        
        // Then - First page
        #expect(viewModel.users.count == 1)
        
        // When - Second page
        mockNetworkService.mockUsers = secondPageUsers
        await viewModel.loadMore()
        
        // Then - Second page
        #expect(viewModel.users.count == 2)
    }
    
    // MARK: - View Tests
    
    @Test func testUserListViewInitialization() {
        // Given
        let view = UserListView(viewModel: viewModel)
        
        // Then
        #expect(view.loadMoreIndexOffset == 10)
    }
    
    @Test func testNavigationTitle() {
        // Given
        let view = UserListView(viewModel: viewModel)
        
        // When
        let mirror = Mirror(reflecting: view.body)
        
        // Then
        let hasNavigationTitle = mirror.children.contains { child in
            if let view = child.value as? ModifiedContent<NavigationView<ScrollView<LazyVStack<ForEach<[GitHubUser], Int, NavigationLink<UserRow, UserDetailView>>>>>, _NavigationViewTitleKey> {
                return view.title == "Github Users"
            }
            return false
        }
        #expect(hasNavigationTitle)
    }
}

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {
    var mockUsers: [GitHubUser] = []
    var shouldFail = false
    
    func fetchUsers(since: Int) async throws -> [GitHubUser] {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return mockUsers
    }
    
    func fetchUserDetail(username: String) async throws -> GitHubUserDetail {
        throw NetworkError.invalidResponse // Not needed for these tests
    }
} 