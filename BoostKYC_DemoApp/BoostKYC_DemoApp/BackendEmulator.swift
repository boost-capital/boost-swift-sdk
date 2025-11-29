//
//  BackendEmulator.swift
//  BoostKYC_DemoApp
//
//  Created by Oleh Hrechyn on 28.11.2025.
//  Copyright © 2025 Boost Capital. All rights reserved.
//

import Foundation

// MARK: - Models & Errors

nonisolated struct SessionTokenResponse: Decodable, Sendable {
    let sessionToken: String
    
    enum CodingKeys: String, CodingKey {
        case sessionToken = "x-session-token"
    }
}

enum BackendError: Error, LocalizedError {
    case apiKeyNotConfigured
    case noData
    case invalidJson
    case invalidUrl
    case network(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured: return "API Key is not configured."
        case .noData: return "Server returned no data."
        case .invalidJson: return "Failed to parse server response."
        case .invalidUrl: return "Invalid URL."
        case .network(let error): return "Network error: \(error.localizedDescription)"
        }
    }
}

private enum Constants {
    static let baseURL = "https://ekyc-core-1019050071398.us-central1.run.app"
    static let inProgressValue = "in_progress"
    
    enum Path {
        static let createSession = "/sessions/create"
        static let fullResults = "/async_sdk/full_results"
    }
}

// MARK: - Emulator Service

final class BackendEmulator {
    
    static let shared = BackendEmulator()
    
    private var apiKey: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
    }
    
    func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - API Methods
    
    func createSession(completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = apiKey else {
            completion(.failure(BackendError.apiKeyNotConfigured))
            return
        }
        
        guard let url = URL(string: Constants.baseURL + Constants.Path.createSession) else {
            completion(.failure(BackendError.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        request.debug()
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(BackendError.network(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                httpResponse.debug(with: data)
            }
            
            guard let data = data else {
                completion(.failure(BackendError.noData))
                return
            }
            
            do {
                let result = try self.decoder.decode(SessionTokenResponse.self, from: data)
                print("[BackendEmulator] Token received: \(result.sessionToken)")
                completion(.success(result.sessionToken))
            } catch {
                print("[BackendEmulator] Decoding error: \(error)")
                completion(.failure(BackendError.invalidJson))
            }
        }
        task.resume()
    }
    
    func getFullResults(token: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: Constants.baseURL + Constants.Path.fullResults) else {
            completion(.failure(BackendError.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "x-session-token")
        
        request.debug()
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(BackendError.network(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                httpResponse.debug(with: data)
            }
            
            guard let data = data else {
                completion(.failure(BackendError.noData))
                return
            }
            
            do {
                // Deserialize to Any first to check for "in_progress" recursively
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Check if ANY field in the JSON structure has the value "in_progress"
                if self.containsInProgressStatus(jsonObject) {
                    print("[BackendEmulator] Found 'in_progress' status. Retrying in 5s...")
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
                        self.getFullResults(token: token, completion: completion)
                    }
                    return
                }
                
                // If finished, return the Dictionary (if valid)
                if let jsonDict = jsonObject as? [String: Any] {
                    print("[BackendEmulator] Final results received.")
                    completion(.success(jsonDict))
                } else {
                    // Edge case: Response is an Array, but we expect a Dictionary
                    completion(.failure(BackendError.invalidJson))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Recursive Helper
    
    /// Recursively checks if any value in the JSON structure equals "in_progress".
    /// Handles nested Dictionaries and Arrays.
    private func containsInProgressStatus(_ value: Any) -> Bool {
        // 1. Check String value
        if let stringValue = value as? String {
            return stringValue == Constants.inProgressValue
        }
        
        // 2. Check Dictionary values
        if let dict = value as? [String: Any] {
            for (_, val) in dict {
                if containsInProgressStatus(val) {
                    return true
                }
            }
        }
        
        // 3. Check Array elements
        if let array = value as? [Any] {
            for element in array {
                if containsInProgressStatus(element) {
                    return true
                }
            }
        }
        
        return false
    }
}

// MARK: - Debug Extensions

fileprivate extension URLRequest {
    func debug() {
        print("[BackendEmulator] Request: \(httpMethod ?? "N/A") \(url?.absoluteString ?? "N/A")")
    }
}

fileprivate extension HTTPURLResponse {
    func debug(with data: Data?) {
        print("[BackendEmulator] Response: \(statusCode)")
        if let data = data, let body = String(data: data, encoding: .utf8) {
            print("[BackendEmulator] Body: \(body)")
        }
    }
}
