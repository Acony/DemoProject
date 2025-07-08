// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GithubUserDetailEntity.swift instead.

import Foundation
import CoreData

public enum GithubUserDetailEntityAttributes: String {
    case avatarUrl = "avatarUrl"
    case followers = "followers"
    case following = "following"
    case htmlUrl = "htmlUrl"
    case id = "id"
    case location = "location"
    case login = "login"
}

public enum GithubUserDetailEntityRelationships: String {
    case user = "user"
}

open class _GithubUserDetailEntity: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "GithubUserDetailEntity"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<GithubUserDetailEntity> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _GithubUserDetailEntity.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var avatarUrl: String?

    @NSManaged open
    var followers: Int32 // Optional scalars not supported

    @NSManaged open
    var following: Int32 // Optional scalars not supported

    @NSManaged open
    var htmlUrl: String?

    @NSManaged open
    var id: Int64 // Optional scalars not supported

    @NSManaged open
    var location: String?

    @NSManaged open
    var login: String?

    // MARK: - Relationships

    @NSManaged open
    var user: GithubUserEntity?

}

