import Foundation
import CoreData

@objc(GithubUserEntity)
open class GithubUserEntity: _GithubUserEntity {
	// Custom logic goes here.
}

extension GithubUserEntity: ManagedModelProtocol {
    
    typealias UIModel = GitHubUser
    
    var asUIModel: GitHubUser {
        return GitHubUser(id: Int(self.id),
                          login: self.login ?? "",
                          avatarUrl: self.avatarUrl ?? "",
                          htmlUrl: self.htmlUrl ?? "")
    }
    
    func update(from uiModel: GitHubUser) {
        self.id = Int64(uiModel.id)
        self.login = uiModel.login
        self.avatarUrl = uiModel.avatarUrl
        self.htmlUrl = uiModel.htmlUrl
    }
}
