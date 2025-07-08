//
//  Untitled.swift
//  test1
//
//  Created by Thanh Quang on 30/5/25.
//

struct GitHubUserDetail: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let location: String?
    let followers: Int
    let following: Int
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case location
        case followers
        case following
        case htmlUrl = "html_url"
    }
}
