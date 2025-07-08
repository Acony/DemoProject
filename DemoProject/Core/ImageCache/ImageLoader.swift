//
//  ImageLoader.swift
//  test1
//
//  Created by Thanh Quang on 13/4/25.
//

import Combine
import UIKit
import SwiftUICore

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

actor ImageLoader {
    
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    private var images: [URLRequest: LoaderStatus] = [:]

    init() {
        setupFileManager()
    }
    
    nonisolated private func setupFileManager() {
        let fileManager = FileManager.default

        // Define the Application Support directory
        let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        // Create the directory if it doesn't exist
        do {
            try fileManager.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
//            print("Directory created or already exists: \(applicationSupportDirectory.path)")
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
        }
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
    
    private func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }

        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }

    private func fileName(for urlRequest: URLRequest) -> URL? {
        
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                  return nil
              }
        
        
        guard let decodedFileName = fileName.removingPercentEncoding else {
            print("Decoded File Name: \(fileName)")
            return nil
        }
        return applicationSupport.appendingPathComponent(sanitizeFileName(from: decodedFileName))
    }
    
    private func sanitizeFileName(from url: String) -> String {
        // Remove invalid characters and replace them with underscores
        let invalidCharacters = CharacterSet(charactersIn: "/:?*<>|\\\"")
        let sanitized = url.components(separatedBy: invalidCharacters).joined(separator: "_")
        return sanitized
    }

//    let originalURL = "https://avatars.githubusercontent.com/u/101?v=4"
//    let sanitizedFileName = sanitizeFileName(from: originalURL)
//    print("Sanitized File Name: \(sanitizedFileName)")
    
    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: 0.8) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return
        }

        try data.write(to: url)
    }

}

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

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
