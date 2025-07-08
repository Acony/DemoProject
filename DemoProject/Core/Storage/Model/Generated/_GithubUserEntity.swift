// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GithubUserEntity.swift instead.

import Foundation
import CoreData

public enum GithubUserEntityAttributes: String {
    case avatarUrl = "avatarUrl"
    case htmlUrl = "htmlUrl"
    case id = "id"
    case login = "login"
}

public enum GithubUserEntityRelationships: String {
    case userDetail = "userDetail"
}

open class _GithubUserEntity: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "GithubUserEntity"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<GithubUserEntity> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _GithubUserEntity.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var avatarUrl: String?

    @NSManaged open
    var htmlUrl: String?

    @NSManaged open
    var id: Int64 // Optional scalars not supported

    @NSManaged open
    var login: String?

    // MARK: - Relationships

    @NSManaged open
    var userDetail: GithubUserDetailEntity?

}

