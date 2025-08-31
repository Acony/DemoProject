//
//  GithubUserDetailViewModel.swift
//  DemoProject
//
//  Created by Thanh Quang on 28/5/25.
//

import Combine

class GithubUserDetailViewModel: ObservableObject {
    
    @MainActor @Published var userDetail: GitHubUserDetail?
    @Published var error: NetworkError?

    private let gitHubUserDetailUseCase: GitHubUserDetailUseCase

    init(gitHubUserDetailUseCase: GitHubUserDetailUseCase = GithubUserDetailDataProvider()) {
        self.gitHubUserDetailUseCase = gitHubUserDetailUseCase
    }
    
    func fetchUserDetail(from username: String) async {
        for await userDetail in gitHubUserDetailUseCase.fetchCachedAndNetworkData(from: username) {
            await MainActor.run {
                self.userDetail = userDetail
            }
        }
//        do {
//            let userDetailEndpoint = UserDetailEndpoint(loginUsername: username)
//            let userDetail: GitHubUserDetail = try await networkManager.fetch(from: userDetailEndpoint)
////            try await detailDBManager.store(userDetail: userDetail)
////            let result = await detailDBManager.getUserDetail(from: userDetail.login)
////            print(result)
//            await MainActor.run {
//                self.userDetail = userDetail
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
    }
    
}

