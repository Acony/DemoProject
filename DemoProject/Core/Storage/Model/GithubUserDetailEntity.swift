import Foundation

@objc(GithubUserDetailEntity)
open class GithubUserDetailEntity: _GithubUserDetailEntity {
	// Custom logic goes here.
}

extension GithubUserDetailEntity: ManagedModelProtocol {
    
    typealias UIModel = GitHubUserDetail

    func update(from uiModel: GitHubUserDetail) {
        self.id = Int64(uiModel.id)
        self.login = uiModel.login
        self.avatarUrl = uiModel.avatarUrl
        self.location = uiModel.location
        self.followers = Int32(uiModel.followers)
        self.following = Int32(uiModel.following)
        self.htmlUrl = uiModel.htmlUrl
    }
    
    var asUIModel: GitHubUserDetail {
        GitHubUserDetail(id: Int(self.id),
                         login: self.login ?? "",
                         avatarUrl: self.avatarUrl ?? "",
                         location: self.location ?? "",
                         followers: Int(self.followers),
                         following: Int(self.following),
                         htmlUrl: self.htmlUrl ?? "")
    }
}
