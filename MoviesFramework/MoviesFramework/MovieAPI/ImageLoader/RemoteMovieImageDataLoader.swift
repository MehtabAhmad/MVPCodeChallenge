//
//  RemoteMovieImageDataLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 15/01/2023.
//

import Foundation


public final class RemoteMovieImageDataLoader: ImageDataLoader {
    private let client: HTTPClient
    private let baseUrl:String
    
    public init(client: HTTPClient, baseUrl:String) {
        self.client = client
        self.baseUrl = baseUrl
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        
        let imgURL = URL(string: baseUrl+url.absoluteString)!
        
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: imgURL) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                guard response.statusCode == 200, !data.isEmpty else {
                    return task.complete(with: .failure(Error.invalidData))
                }
                task.complete(with: .success(data))
                
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        
        return task
    }
}
