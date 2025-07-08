//
//  GitHubUse.swift
//  test1
//
//  Created by Thanh Quang on 30/5/25.
//

protocol GitHubUserUseCase {
    func fetchCachedAndNetworkData(from userId: Int, limit: Int) -> AsyncStream<[GitHubUser]>
}
