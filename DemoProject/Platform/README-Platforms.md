# Platform Layer Documentation

The Platform layer implements the data providers and repositories that handle data operations in the application. This layer is responsible for managing data sources, caching, and network operations.

## Architecture

The Platform layer follows the Repository pattern and implements the Use Case interfaces defined in the Domain layer. It provides concrete implementations for:
- Data fetching from network
- Local data caching
- Data synchronization between network and local storage

## Components

### 1. GithubUserDataProvider

Implements `GitHubUserUseCase` and manages GitHub user data operations.

```swift
class GithubUserDataProvider: GitHubUserUseCase {
    func fetchCachedAndNetworkData(from userId: Int, limit: Int) -> AsyncStream<[GitHubUser]>
    func getUsersFromDB(from userId: Int, limit: Int) async -> [GitHubUser]?
}
```

#### Features:
- Fetches users from both local database and network
- Implements caching strategy with local-first approach
- Handles pagination with `userId` and `limit` parameters
- Uses `AsyncStream` for reactive data updates

#### Usage Example:
```swift
let provider = GithubUserDataProvider()
let usersStream = provider.fetchCachedAndNetworkData(from: 0, limit: 20)

for await users in usersStream {
    // Handle users update
}
```

### 2. GithubUserDetailDataProvider

Implements `GitHubUserDetailUseCase` and manages detailed user information.

```swift
class GithubUserDetailDataProvider: GitHubUserDetailUseCase {
    func fetchCachedAndNetworkData(from username: String) -> AsyncStream<GitHubUserDetail>
    func getUserDetailFromDB(_ username: String) async -> GitHubUserDetail?
}
```

#### Features:
- Fetches user details from both local database and network
- Implements caching strategy for user details
- Uses username as unique identifier
- Provides reactive updates through `AsyncStream`

#### Usage Example:
```swift
let provider = GithubUserDetailDataProvider()
let detailStream = provider.fetchCachedAndNetworkData(from: "username")

for await userDetail in detailStream {
    // Handle user detail update
}
```

## Data Flow

1. **Local-First Strategy**
   - Check local database first
   - Return cached data if available
   - Fetch from network in background
   - Update cache with new data
   - Emit updates through AsyncStream

2. **Error Handling**
   - Network errors are logged
   - Local cache serves as fallback
   - Errors don't interrupt the stream

## Dependencies

- `NetworkManaging`: Protocol for network operations
- `GithubUserDBProtocol`: Protocol for user data persistence
- `GithubUserDetailDBProtocol`: Protocol for user detail persistence

## Best Practices

1. **Caching Strategy**
   - Always cache network responses
   - Implement cache invalidation
   - Use appropriate cache duration

2. **Error Handling**
   - Log all errors for debugging
   - Provide fallback data when possible
   - Maintain app stability during errors

3. **Performance**
   - Use pagination for large datasets
   - Implement efficient database queries
   - Optimize network requests

## Testing

When testing Platform layer components:

1. Mock network manager for testing network operations
2. Mock database repositories for testing persistence
3. Test both success and failure scenarios
4. Verify caching behavior
5. Test pagination and data updates

Example test setup:
```swift
class MockNetworkManager: NetworkManaging {
    var mockResponse: Any?
    var shouldFail = false
    
    func fetch<T>(from endpoint: Endpoint) async throws -> T {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return mockResponse as! T
    }
}
```

## Contributing

When adding new features to the Platform layer:

1. Implement appropriate interfaces from Domain layer
2. Follow existing patterns for consistency
3. Add comprehensive error handling
4. Include unit tests
5. Update documentation 