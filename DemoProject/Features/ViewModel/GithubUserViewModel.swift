//
//  GithubUserViewModel.swift
//  test1
//
//  Created by Thanh Quang on 28/5/25.
//

import Combine

class GithubUserViewModel: ObservableObject {
    
    @MainActor @Published var users: [GitHubUser] = []
    
    private static let perPage = 20
    private(set) var lastUserId: Int = 0
    private(set) var isLoading = false

    private let gitHubUserCase: GitHubUserUseCase
    
    var error: NetworkError?

    init(gitHubUserCase: GitHubUserUseCase = GithubUserDataProvider()) {
        self.gitHubUserCase = gitHubUserCase
    }
    
    func fetchUsers(from userId: Int, limit: Int = GithubUserViewModel.perPage) async {
        guard !isLoading else { return }
        isLoading = true
        print("fetchUsers since = \(lastUserId)")
        
        for await users in gitHubUserCase.fetchCachedAndNetworkData(from: userId, limit: limit) {
            await MainActor.run {
                self.lastUserId = users.last?.id ?? self.lastUserId
                self.addUsers(users)
            }
        }
//
//        do {
//            let userEndpoint = UserEndpoint(page: limit, since: userId)
//            let users: [GitHubUser] = try await networkManager.fetch(from: userEndpoint)
//            self.lastUserId = users.last!.id
//            await MainActor.run {
//                self.users.append(contentsOf: users)
//                
//            }
//        } catch let error as NetworkError {
//            await MainActor.run {
//                self.error = error
//            }
//            
//        } catch {
//            await MainActor.run {
//                self.error = .unknownError(0)
//            }
//        }
        isLoading = false
    }
    
    @MainActor func addUsers(_ fetchedUsers: [GitHubUser]) {
        var curUsers = users
        let curUserIdSet = Set(curUsers.map{$0.id})
        var hasUpdated = false
        for fetchedUser in fetchedUsers {
            if !curUserIdSet.contains(fetchedUser.id) {
                curUsers.append(fetchedUser)
                hasUpdated = true
            }
        }
        if hasUpdated {
            users = curUsers.sorted(by: {$0.id < $1.id})
        }
    }
    
    func loadMore() async {
        await fetchUsers(from: self.lastUserId)
    }
}

