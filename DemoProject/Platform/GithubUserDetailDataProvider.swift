//
//  GithubUserDetailDataProvider.swift
//  test1
//
//  Created by Thanh Quang on 30/5/25.
//

class GithubUserDetailDataProvider: GitHubUserDetailUseCase {
    
    private let networkManager: NetworkManaging
    private let detailDBManager: GithubUserDetailDBProtocol = GithubUserDetailDBRepository()
    
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchCachedAndNetworkData(from username: String) -> AsyncStream<GitHubUserDetail> {
        return AsyncStream { continuation in
            Task {
                if let localUserDetail = await getUserDetailFromDB(username) {
                    continuation.yield(localUserDetail)
                }
                
                do {
                    let userDetailEndpoint = UserDetailEndpoint(loginUsername: username)
                    let userDetail: GitHubUserDetail = try await networkManager.fetch(from: userDetailEndpoint)
                    try await detailDBManager.store(userDetail: userDetail)
                    continuation.yield(userDetail)
                } catch {
                    print("fetchCachedAndNetworkData error \(error)")
                }
                continuation.finish()
            }
        }
    }
    
    func getUserDetailFromDB(_ username: String) async -> GitHubUserDetail? {
        let userDetail = await detailDBManager.getUserDetail(from: username)
        return userDetail
    }
}
