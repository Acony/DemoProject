import XCTest
import Testing
@testable import DemoProject

final class StorageTests: XCTestCase {
    var storage: Storage!
    
    override func setUp() {
        super.setUp()
        storage = Storage.shared
        storage.clearAll()
    }
    
    override func tearDown() {
        storage.clearAll()
        super.tearDown()
    }
    
    @Test func testSaveAndFetch() throws {
        // Given
        let testUser = User(id: 1, name: "Test User")
        let key = "testUser"
        
        // When
        storage.save(object: testUser, forKey: key)
        
        // Then
        let fetchedUser = storage.fetch(type: User.self, forKey: key)
        #expect(fetchedUser?.id == testUser.id)
        #expect(fetchedUser?.name == testUser.name)
    }
    
    @Test func testDelete() throws {
        // Given
        let testUser = User(id: 1, name: "Test User")
        let key = "testUser"
        storage.save(object: testUser, forKey: key)
        
        // When
        storage.delete(forKey: key)
        
        // Then
        let fetchedUser = storage.fetch(type: User.self, forKey: key)
        #expect(fetchedUser == nil)
    }
    
    @Test func testClearAll() throws {
        // Given
        let testUser1 = User(id: 1, name: "Test User 1")
        let testUser2 = User(id: 2, name: "Test User 2")
        storage.save(object: testUser1, forKey: "user1")
        storage.save(object: testUser2, forKey: "user2")
        
        // When
        storage.clearAll()
        
        // Then
        let fetchedUser1 = storage.fetch(type: User.self, forKey: "user1")
        let fetchedUser2 = storage.fetch(type: User.self, forKey: "user2")
        #expect(fetchedUser1 == nil)
        #expect(fetchedUser2 == nil)
    }
    
    @Test func testUpdateExisting() throws {
        // Given
        let testUser = User(id: 1, name: "Test User")
        let key = "testUser"
        storage.save(object: testUser, forKey: key)
        
        // When
        let updatedUser = User(id: 1, name: "Updated User")
        storage.save(object: updatedUser, forKey: key)
        
        // Then
        let fetchedUser = storage.fetch(type: User.self, forKey: key)
        #expect(fetchedUser?.name == "Updated User")
    }
}

// Test Model
struct User: Codable, Equatable {
    let id: Int
    let name: String
} 