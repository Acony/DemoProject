//
//  NetworkManager.swift
//  DemoProject
//
//  Created by Thanh Quang on 4/4/25.
//

import Foundation
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidResponse
    case decodingFailed
    case clientError(Int)
    case serverError(Int)
    case unknownError(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response received from the server."
        case .decodingFailed:
            return "Failed to decode the response data."
        case .clientError(let statusCode):
            return "Client error occurred. Status code: \(statusCode)"
        case .serverError(let statusCode):
            return "Server error occurred. Status code: \(statusCode)"
        case .unknownError(let statusCode):
            return "An unknown error occurred. Status code: \(statusCode)"
        }
    }
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

extension Endpoint {
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let parameters = parameters {
            if method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            }
        }
        
        return request
    }
}

protocol NetworkManaging {
    func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T
}

final class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T {
        let request = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        try validateResponse(httpResponse)
        
        // Debug
//        print(data.dataToJSONString())
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("fetch with error = \(error)")
            throw error
        }
    }
    
    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400...499:
            throw NetworkError.clientError(response.statusCode)
        case 500...599:
            throw NetworkError.serverError(response.statusCode)
        default:
            throw NetworkError.unknownError(response.statusCode)
        }
    }
}

struct Host {
    static let baseURL = URL(string: "https://api.github.com")!
    static let TOKEN = "INPUT YOU TOKEN HERE"
}

extension Endpoint {
    
    var baseURL: URL {
        Host.baseURL
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json",
         "Authorization": "Bearer \(Host.TOKEN)"]
    }
    
    var parameters: [String : Any]? {
        nil
    }
}

struct UserEndpoint: Endpoint {
    
    let page: Int
    let since: Int
    
    var path: String {
        "/users"
    }
    
    var parameters: [String : Any]? {
        [
            "per_page": page,
            "since": since
        ]
    }
}

struct UserDetailEndpoint: Endpoint {
    
    let loginUsername: String
    
    var path: String {
        "/users/\(loginUsername)"
    }
}

extension Data {
    func dataToJSONString() -> String? {
        let data = self
        
        do {
            // Step 1: Deserialize the Data to a Foundation object (e.g. Dictionary or Array)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Step 2: Convert back to Data (pretty printed)
            let prettyData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted]
            )
            
            // Step 3: Convert Data to String
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("Error converting Data to JSON String: $error)")
            return nil
        }
    }
}
