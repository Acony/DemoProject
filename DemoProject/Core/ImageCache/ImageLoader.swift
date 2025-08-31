//
//  ImageLoader.swift
//  DemoProject
//
//  Created by Thanh Quang on 13/4/25.
//

import Combine
import UIKit
import SwiftUICore

// MARK: - Configuration

struct ImageLoaderConfiguration {
    let storagePath: String
    let compressionQuality: CGFloat
    
    init(storagePath: String = "", compressionQuality: CGFloat = 0.8) {
        self.storagePath = storagePath
        self.compressionQuality = compressionQuality
    }
    
    static let `default` = ImageLoaderConfiguration()
}

// MARK: - Cache Protocol

protocol ImageCacheProtocol {
    func getImage(for url: String) -> UIImage?
    func setImage(_ image: UIImage, for url: String)
}

class ImageCache: ImageCacheProtocol {
    
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    func getImage(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}

// MARK: - ImageLoader Protocol

protocol ImageLoaderProtocol {
    func fetch(_ url: URL) async throws -> UIImage
    func cleanUp() async
}

// MARK: - ImageLoader Implementation

actor ImageLoader: ImageLoaderProtocol {
    
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    private var images: [URLRequest: LoaderStatus] = [:]
    private let configuration: ImageLoaderConfiguration
    
    // MARK: - Initialization
    
    init(configuration: ImageLoaderConfiguration = .default) {
        self.configuration = configuration
        setupFileManager()
    }
    
    // MARK: - Public Methods
    
    func cleanUp() async {
        images = [:]
    }
    
    public func fetch(_ url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }

    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        // fetch image by URLRequest
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        if let image = try? self.imageFromFileSystem(for: urlRequest) {
            images[urlRequest] = .fetched(image)
            return image
        }
        
        let task: Task<UIImage, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)!
            try self.persistImage(image, for: urlRequest)
            return image
        }
        
        images[urlRequest] = .inProgress(task)
        
        let image = try await task.value
        
        images[urlRequest] = .fetched(image)
        
        return image
    }
    
    // MARK: - Private Methods
    
    nonisolated private func setupFileManager() {
        let fileManager = FileManager.default
        let storageDirectory = getStorageDirectory()

        // Create the directory if it doesn't exist
        do {
            try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true, attributes: nil)
//            print("Directory created or already exists: \(storageDirectory.path)")
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
        }
    }
    
    nonisolated private func getStorageDirectory() -> URL {
        let fileManager = FileManager.default
        
        if configuration.storagePath.isEmpty {
            // Use default Application Support directory
            return fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        } else {
            // Use custom path
            let customPath = URL(fileURLWithPath: configuration.storagePath)
            
            // If it's a relative path, make it relative to Application Support
            if !customPath.hasDirectoryPath {
                let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                return applicationSupport.appendingPathComponent(configuration.storagePath, isDirectory: true)
            } else {
                return customPath
            }
        }
    }
    
    private func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }

        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }

    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        let storageDirectory = getStorageDirectory()
        
        guard let decodedFileName = fileName.removingPercentEncoding else {
            print("Decoded File Name: \(fileName)")
            return nil
        }
        
        return storageDirectory.appendingPathComponent(sanitizeFileName(from: decodedFileName))
    }
    
    private func sanitizeFileName(from url: String) -> String {
        // Remove invalid characters and replace them with underscores
        let invalidCharacters = CharacterSet(charactersIn: "/:?*<>|\\\"")
        let sanitized = url.components(separatedBy: invalidCharacters).joined(separator: "_")
        return sanitized
    }
    
    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: configuration.compressionQuality) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return
        }

        try data.write(to: url)
    }
}

// MARK: - Environment Integration

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

// MARK: - RemoteImage View

struct RemoteImage: View {
    private let source: URLRequest
    @State private var image: UIImage?

    @Environment(\.imageLoader) private var imageLoader

    init(source: URL) {
        self.init(source: URLRequest(url: source))
    }

    init(source: URLRequest) {
        self.source = source
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .background(Color.red)
            }
        }
        .task {
            await loadImage(at: source)
        }
    }

    func loadImage(at source: URLRequest) async {
        do {
            image = try await imageLoader.fetch(source)
        } catch {
            print(error)
        }
    }
}
