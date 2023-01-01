//
//  RemoteMovieLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

final public class RemoteMovieLoader: LoadMovieUseCase {
    private let client:HTTPClient
    private let url:URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadMovieResult
    
    public init(client:HTTPClient, url:URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion:@escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(MovieItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
