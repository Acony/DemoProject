//
//  Untitled.swift
//  test1
//
//  Created by Thanh Quang on 30/5/25.
//

class GithubUserDataProvider: GitHubUserUseCase {
    
    private let networkManager: NetworkManaging
    private let detailDBManager: GithubUserDBProtocol = GithubUserDBRepository()
    
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchCachedAndNetworkData(from userId: Int, limit: Int) -> AsyncStream<[GitHubUser]> {
        return AsyncStream { continuation in
            Task {
                
                // Get from DB
                if let localUsers = await getUsersFromDB(from: userId, limit: limit) {
                    continuation.yield(localUsers)
                }
                
                // Get from network
                do {
                    let userEndpoint = UserEndpoint(page: limit, since: userId)
                    let users: [GitHubUser] = try await networkManager.fetch(from: userEndpoint)
                    try await detailDBManager.store(users: users)
                    continuation.yield(users)
                } catch {
                    print("fetchCachedAndNetworkData error \(error)")
                }
                continuation.finish()
            }
        }
    }
    
    func getUsersFromDB(from userId: Int, limit: Int) async -> [GitHubUser]? {
        let users = await detailDBManager.getUsers(from: userId, limit)
        return users
    }

}
