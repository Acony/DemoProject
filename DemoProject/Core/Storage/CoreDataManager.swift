//
//  CoreDataManager.swift
//  test1
//
//  Created by Thanh Quang on 4/4/25.
//


import Foundation
import CoreData
import Combine

// MARK: - Core Data Model
 

protocol GithubUserDBProtocol {
    func store(users: [GitHubUser]) async throws
    func getUsers(from userId: Int, _ limit: Int) async -> [GitHubUser]
}

protocol GithubUserDetailDBProtocol {
    func store(userDetail: GitHubUserDetail) async throws
    func getUserDetail(from name: String) async -> GitHubUserDetail?
}

struct GithubUserDBRepository: GithubUserDBProtocol {
    
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage = CoreDataStorage.shared) {
        self.storage = storage
    }
    
    func store(users: [GitHubUser]) async throws {
        var userIdMap = [Int: GitHubUser]()
        for user in users {
            userIdMap[user.id] = user
        }
        
        let ids = Array(userIdMap.keys)
        
        let fetchRequest: NSFetchRequest<GithubUserEntity> = GithubUserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN  %@", ids as CVarArg)

        await storage.update { context in
            var result: [GithubUserEntity]?
            do {
                result = try context.fetch(fetchRequest)
                
                for id in ids {
                    
                    if let user = result?.first(where: {$0.id == id}) {
                        user.update(from: userIdMap[id]!)
                    } else {
                        let user = GithubUserEntity.init(managedObjectContext: context)
                        user?.update(from: userIdMap[id]!)
                    }
                }
                try context.save()
            } catch {
                
            }
        }
    }
    
    func getAllUsers() -> [GitHubUser] {
        
//        let fetchRequest: NSFetchRequest<ListItem> = ListItem.fetchRequest()
//        do {
//            
//            let listArray = try persistentContainer.viewContext.fetch(fetchRequest)
//            
//            var localArray = [LocalListModel]()
//            
//            for itemObject in listArray {
//                localArray.append(LocalListModel(title: itemObject.title, subDescription: itemObject.subdescription, date: itemObject.date, image: itemObject.image))
//            }
//            
//            //Short data based on date and return new data set
//            return localArray.sorted(by: { $0.date?.compare($1.date ?? Date()) == .orderedDescending })
//        } catch {
//            return []
//        }
        
        return []
    }
    
    func getUsers(from userId: Int, _ limit: Int) async -> [GitHubUser] {
        
        let fetchRequest: NSFetchRequest<GithubUserEntity> = GithubUserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id > %d", userId)
        fetchRequest.fetchLimit = limit
        let result = await storage.fetch(fetchRequest)
        return result.map {$0.asUIModel}
    }
}

struct GithubUserDetailDBRepository: GithubUserDetailDBProtocol {
    
    private let storage: CoreDataStorage

    init(storage: CoreDataStorage = CoreDataStorage.shared) {
        self.storage = storage
    }
    
    func store(userDetail: GitHubUserDetail) async throws {
        let fetchRequest = buildFetchRequest(from: userDetail.login)
        await storage.update { context in
            var result: GithubUserDetailEntity?
            do {
                result = try context.fetch(fetchRequest).first
                if result == nil {
                    result = GithubUserDetailEntity(managedObjectContext: context)
                    result?.update(from: userDetail)
                }
                try context.save()
            } catch {
                
            }
        }
    }
    
    func getUserDetail(from name: String) async -> GitHubUserDetail? {
        let fetchRequest = buildFetchRequest(from: name)
        let result = await storage.fetch(fetchRequest)
        return result.first?.asUIModel
    }
    
    func buildFetchRequest(from name: String) -> NSFetchRequest<GithubUserDetailEntity> {
        let fetchRequest: NSFetchRequest<GithubUserDetailEntity> = GithubUserDetailEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login = %@", name)
        return fetchRequest
    }
}

protocol Storage {
    
}

protocol BaseManagedModelProtocol: NSManagedObject {
    associatedtype UIModel
}

protocol BaseUIModelProtocol: Equatable {
    associatedtype ManagedModel
}

/*
protocol ManagedModelProtocol: BaseManagedModelProtocol where UIModel: BaseUIModelProtocol, UIModel.ManagedModel == Self {
    var asUIModel: UIModel { get }
//    func create(from uiModel: UIModel)
    func update(from uiModel: UIModel)
}

protocol UIModelProtocol: BaseUIModelProtocol where ManagedModel: BaseManagedModelProtocol, ManagedModel.UIModel == Self {
    func convertToManagedModel(in context: NSManagedObjectContext) -> ManagedModel
}
 */

protocol ManagedModelProtocol: BaseManagedModelProtocol {
    var asUIModel: UIModel { get }
    func update(from uiModel: UIModel)
}

class CoreDataStorage {
    
    static let shared = CoreDataStorage()
    
    private let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
        
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.container = container
        self.backgroundContext = container.newBackgroundContext()
        self.viewContext = container.viewContext
    }
//    // MARK: - Core Data stack
//    private lazy var persistentContainer: NSPersistentContainer = {
//        container.loadPersistentStores { _, error in
//            if let error = error as NSError? {
//                // TODO: - Log to Crashlytics
//                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
    
    func fetch<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) async -> [T] {
//        assert(Thread.isMainThread)
        var result: [T] = []
        let context = viewContext
        await context.perform {
            do {
                result = try context.fetch(fetchRequest)
            } catch {
//                return []
            }
        }
        return result
    }
    
//    func fetch<T: ManagedModelProtocol>(_ fetchRequest: NSFetchRequest<T>) async -> [T.UIModel] {
//        assert(Thread.isMainThread)
//        let context = container.viewContext
//        var result: [T.UIModel] = []
//        await context.perform {
//            do {
//                let managedObjects = try context.fetch(fetchRequest)
//                result = managedObjects.map{$0.asUIModel}
//
//            } catch {
////                return []
//            }
//        }
//        
//        return result
//    }
    
//    func save<T: ManagedModelProtocol>(_ values: [T]) async {
    func saveContext() async {
        if !backgroundContext.hasChanges {return}
        await backgroundContext.perform {
            do {
                try self.backgroundContext.save()
            } catch {
                assertionFailure("CoreDataStorage save error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func update(_ block: @escaping (NSManagedObjectContext) -> ()) async {
        await backgroundContext.perform {
            block(self.backgroundContext)
        }
    }
//
//            context.performAndWait {
//                do {
//                    let managedObjects = try context.fetch(fetchRequest)
//                    let results = LazyList<V>(count: managedObjects.count,
//                                              useCache: true) { [weak context] in
//                        let object = managedObjects[$0]
//                        let mapped = try map(object)
//                        if let mo = object as? NSManagedObject {
//                            // Turning object into a fault
//                            context?.refresh(mo, mergeChanges: false)
//                        }
//                        return mapped
//                    }
//                    promise(.success(results))
//                } catch {
//                    promise(.failure(error))
//                }
//            }
//        }
//        return onStoreIsReady
//            .flatMap { fetch }
//            .eraseToAnyPublisher()
//    }

    // MARK: - Core Data Saving support
//    func saveContext() {
//        let context = persistentContainer.newBackgroundContext()
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // TODO: - Log to Crashlytics
//                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
//            }
//        }
//    }

//    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
//        persistentContainer.performBackgroundTask(block)
//    }

}

/*
// This would normally be created in the .xcdatamodeld file
// For reference, here's what the entity would look like:
/*
 Entity: GitHubUserEntity
 Attributes:
 - id: Integer 64
 - login: String
 - avatarUrl: String
 - htmlUrl: String
 */

// MARK: - Core Data Manager
class CoreDataManager {
    static let shared = CoreDataManager()
    
    // MARK: - Core Data Stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubUsers")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Background context for operations
    private func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - CRUD Operations
    
    // Save GitHub users to Core Data
    func saveUsers(_ users: [GitHubUser]) async throws {
        let context = backgroundContext()
        
        return try await withCheckedThrowingContinuation { continuation in
            
            context.perform {
                do {
                    
                } catch {
                    
                }
            }
//            context.perform {
//                do {
//                    // For each user from the API, create or update a Core Data entity
//                    for user in users {
//                        let fetchRequest: NSFetchRequest<GitHubUserEntity> = GitHubUserEntity.fetchRequest()
//                        fetchRequest.predicate = NSPredicate(format: "id == %lld", user.id)
//                        
//                        // Try to find existing user
//                        let existingUsers = try context.fetch(fetchRequest)
//                        let userEntity: GitHubUserEntity
//                        
//                        if let existingUser = existingUsers.first {
//                            // Update existing user
//                            userEntity = existingUser
//                        } else {
//                            // Create new user
//                            userEntity = GitHubUserEntity(context: context)
//                            userEntity.id = Int64(user.id)
//                        }
//                        
//                        // Update properties
//                        userEntity.login = user.login
//                        userEntity.avatarUrl = user.avatarUrl
//                        userEntity.htmlUrl = user.htmlUrl
//                    }
//                    
//                    // Save context
//                    if context.hasChanges {
//                        try context.save()
//                    }
//                    
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
        }
    }
    
    // Fetch all GitHub users from Core Data
    func fetchUsers() async throws -> [GitHubUser] {
        let context = viewContext
        
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<GitHubUserEntity> = GitHubUserEntity.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
                    
                    let userEntities = try context.fetch(fetchRequest)
                    let users = userEntities.map { entity -> GitHubUser in
                        return GitHubUser(
                            id: Int(entity.id),
                            login: entity.login ?? "",
                            avatarUrl: entity.avatarUrl ?? "",
                            htmlUrl: entity.htmlUrl ?? ""
                        )
                    }
                    
                    continuation.resume(returning: users)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Delete all users
    func deleteAllUsers() async throws {
        let context = backgroundContext()
        
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GitHubUserEntity.fetchRequest()
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    batchDeleteRequest.resultType = .resultTypeObjectIDs
                    
                    let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                    if let objectIDs = result?.result as? [NSManagedObjectID] {
                        let changes = [NSDeletedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                    }
                    
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - GitHubUserEntity Extension for fetchRequest
extension GitHubUserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GitHubUserEntity> {
        return NSFetchRequest<GitHubUserEntity>(entityName: "GitHubUserEntity")
    }
}

// MARK: - Updated ViewModel with Core Data Integration
@Observable
class GitHubUsersViewModel {
    private let apiClient: GitHubAPIClient
    private let coreDataManager: CoreDataManager
    
    // Published properties
    var users: [GitHubUser] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var dataSource: DataSource = .remote
    
    enum DataSource {
        case local
        case remote
    }
    
    init(apiClient: GitHubAPIClient = GitHubAPIClient(), coreDataManager: CoreDataManager = .shared) {
        self.apiClient = apiClient
        self.coreDataManager = coreDataManager
    }
    
    @MainActor
    func fetchUsers(perPage: Int = 20, since: Int = 100, forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        // First try to load from local database if not forcing refresh
        if !forceRefresh {
            do {
                let localUsers = try await coreDataManager.fetchUsers()
                if !localUsers.isEmpty {
                    users = localUsers
                    dataSource = .local
                    isLoading = false
                    return
                }
            } catch {
                // If local fetch fails, continue with remote fetch
                print("Failed to fetch from Core Data: \(error.localizedDescription)")
            }
        }
        
        // Fetch from remote API
        do {
            let remoteUsers = try await apiClient.getUsers(perPage: perPage, since: since)
            users = remoteUsers
            dataSource = .remote
            
            // Save to Core Data in the background
            Task {
                do {
                    try await coreDataManager.saveUsers(remoteUsers)
                    print("Successfully saved users to Core Data")
                } catch {
                    print("Failed to save to Core Data: \(error.localizedDescription)")
                }
            }
        } catch let error as GitHubAPIError {
            switch error {
            case .invalidURL:
                errorMessage = "Invalid URL"
            case .invalidResponse:
                errorMessage = "Invalid server response"
            case .networkError(let err):
                errorMessage = "Network error: \(err.localizedDescription)"
            case .decodingError(let err):
                errorMessage = "Failed to decode data: \(err.localizedDescription)"
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshData() async {
        await fetchUsers(forceRefresh: true)
    }
    
    @MainActor
    func clearLocalData() async {
        do {
            try await coreDataManager.deleteAllUsers()
            users = []
        } catch {
            errorMessage = "Failed to clear local data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Updated Usage Example
struct GitHubUsersView {
    @State private var viewModel = GitHubUsersViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.users) { user in
                        HStack {
                            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(user.login)
                                    .font(.headline)
                                Text(user.htmlUrl)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Show data source indicator
                    Text("Data source: \(viewModel.dataSource == .local ? "Local Storage" : "Remote API")")
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("GitHub Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await viewModel.refreshData()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Cache") {
                        Task {
                            await viewModel.clearLocalData()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}
*/
