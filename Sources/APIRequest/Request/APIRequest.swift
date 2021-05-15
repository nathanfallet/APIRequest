/*
*  Copyright (C) 2020 Groupe MINASTE
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*
*/

import Foundation

public class APIRequest: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    /// Completion handler of an APIRequest
    /// - Parameters:
    ///   - data: The decoded data from API
    ///   - status: The status of the request
    public typealias CompletionHandler<T> = (_ data: T?, _ status: APIResponseStatus) -> () where T: Decodable
    
    /// Upload progress handler of an APIRequest
    /// - Parameters:
    ///   - progress: The current upload progress, between 0 and 1
    public typealias UploadProgress = (_ progress: Double) -> ()
    
    // Object properties
    private var method: String
    private var path: String
    private var configuration: APIConfiguration
    private var headers: [String: String]
    private var queryItems: [URLQueryItem]
    private var body: Data?
    private var contentType: String?
    private var uploadProgress: UploadProgress?
    
    // Task
    private var task: URLSessionDataTask?
    
    /// Create a request to the API
    /// - Parameters:
    ///   - method: The request method (GET, POST, PUT, DELETE, ...)
    ///   - path: The path to the api. Always starts with a /
    ///   - configuration: The configuration of the API. Use the default one if not specified
    public init(_ method: String, path: String, configuration: APIConfiguration? = APIConfiguration.current) {
        // Check that a configuration is specified
        guard let configuration = configuration else {
            // Throw an error
            fatalError("APIConfiguration is nil! Try to set APIConfiguration.current at launch.")
        }
        
        // Get request parameters
        self.method = method
        self.path = path
        self.configuration = configuration
        self.queryItems = []
        self.headers = [:]
    }
    
    /// Add a get parameter
    /// - Parameters:
    ///   - name: The name of the variable
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(name: String) -> APIRequest {
        queryItems.append(URLQueryItem(name: name, value: nil))
        return self
    }
    
    /// Add a get parameter
    /// - Parameters:
    ///   - name: The name of the variable
    ///   - value: The value of the variable
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with<S>(name: String, value: S) -> APIRequest where S: LosslessStringConvertible {
        queryItems.append(URLQueryItem(name: name, value: String(value)))
        return self
    }
    
    /// Add a header to the request
    /// - Parameters:
    ///   - header: The name of the header
    ///   - value: The value of the header
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with<S>(header: String, value: S) -> APIRequest where S: LosslessStringConvertible {
        headers[header] = String(value)
        return self
    }
    
    /// Add a body to the request (for POST or PUT requests)
    /// - Parameters:
    ///   - body: The body of the request
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(body: Data?) -> APIRequest {
        self.body = body
        return self
    }
    
    /// Add a body to the request (for POST or PUT requests)
    /// - Parameters:
    ///   - body: The body of the request
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(body: Encodable) -> APIRequest {
        self.body = configuration.encoder.encode(from: body)
        self.contentType = configuration.encoder.contentType
        return self
    }
    
    /// Add a body to the request (for POST or PUT requests)
    /// - Parameters:
    ///   - body: The body of the request
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(body: [String: Any]) -> APIRequest {
        self.body = configuration.encoder.encode(from: body)
        self.contentType = configuration.encoder.contentType
        return self
    }
    
    /// Add a content type to the request (for POST or PUT requests)
    /// - Parameters:
    ///   - contentType: The content type of the request
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(contentType: String) -> APIRequest {
        self.contentType = contentType
        return self
    }
    
    /// Set a progress handler for upload
    /// - Parameter uploadProgress: The progress handler
    /// - Returns: The modified APIRequest
    @discardableResult
    public func with(uploadProgress: @escaping UploadProgress) -> APIRequest {
        self.uploadProgress = uploadProgress
        return self
    }
    
    // Construct URL
    private func getURL() -> URL? {
        var components = URLComponents()
        components.scheme = configuration.scheme
        components.port = configuration.port
        components.host = configuration.host
        components.path = path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    /// Execute the APIRequest asynchronously
    /// - Parameters:
    ///   - type: The type to decode the received data
    ///   - completionHandler: The completion handler of the request
    @discardableResult
    public func execute<T>(_ type: T.Type, completionHandler: @escaping CompletionHandler<T>) -> APIRequest where T: Decodable {
        // Check url validity
        if let url = getURL() {
            // Create the request based on give parameters
            var request = URLRequest(url: url)
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.httpMethod = method
            request.allowsCellularAccess = configuration.allowsCellularAccess
            
            // Get headers from configuration
            for (key, value) in configuration.headers() {
                request.addValue(value, forHTTPHeaderField: key)
            }
            
            // Get headers from request
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
            
            // Set body
            if let body = body {
                request.httpBody = body
                if let contentType = contentType {
                    request.addValue(contentType, forHTTPHeaderField: "Content-Type")
                }
            }
            
            // Create the session
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
            
            // Launch the request to server
            task = session.dataTask(with: request) { data, response, error in
                // Check if there is an error
                if let error = error {
                    if (error as NSError).code == -1009 {
                        // Device is offline
                        self.end(data: nil, status: .offline, completionHandler: completionHandler)
                        return
                    }
                    // Unknown server error
                    self.end(data: nil, status: .error, completionHandler: completionHandler)
                    return
                }
                
                // Get data and response
                if let data = data, let response = response as? HTTPURLResponse {
                    // Decode the data with the specified decoder
                    self.end(data: self.configuration.decoder.decode(from: data, as: type), status: APIResponseStatus.status(forCode: response.statusCode), completionHandler: completionHandler)
                } else {
                    // We consider we don't have a valid response
                    self.end(data: nil, status: .error, completionHandler: completionHandler)
                }
            }
            task?.resume()
        } else {
            // URL is not valid
            self.end(data: nil, status: .error, completionHandler: completionHandler)
        }
        
        // Return the request object
        return self
    }
    
    /// Cancel the ongoing request
    @discardableResult
    public func cancel() -> APIRequest {
        task?.cancel()
        task = nil
        return self
    }
    
    // End the request and call completion handler
    private func end<T>(data: T?, status: APIResponseStatus, completionHandler: @escaping CompletionHandler<T>) where T: Decodable {
        if configuration.completionInMainThread {
            // Call main thread
            DispatchQueue.main.async {
                // And complete
                completionHandler(data, status)
            }
        } else {
            // Just complete
            completionHandler(data, status)
        }
    }
    
    /// Update the upload state for the request
    /// - Parameters:
    ///   - session: The session
    ///   - task: The task
    ///   - bytesSent: The bytes sent
    ///   - totalBytesSent: The total bytes sent
    ///   - totalBytesExpectedToSend: The total bytes expected to send
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        // Call the upload progress (if specified)
        uploadProgress?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
    
}
