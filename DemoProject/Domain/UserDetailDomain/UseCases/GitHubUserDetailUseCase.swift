//
//  GitHubUserDetailUseCase.swift
//  test1
//
//  Created by Thanh Quang on 30/5/25.
//

protocol GitHubUserDetailUseCase {
    func fetchCachedAndNetworkData(from username: String) -> AsyncStream<GitHubUserDetail>
}
