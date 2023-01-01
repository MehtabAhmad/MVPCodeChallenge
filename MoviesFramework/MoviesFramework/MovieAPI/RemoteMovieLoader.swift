//
//  RemoteMovieLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

final public class RemoteMovieLoader {
    private let client:HTTPClient
    private let url:URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([DomainMovie])
        case failure(Error)
    }
    
    public init(client:HTTPClient, url:URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion:@escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try MovieItemsMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class MovieItemsMapper {
    private struct Root: Decodable {
        let results: [APIMovie]
    }
    
    private struct APIMovie: Decodable {
        public let id:UUID
        public let title:String
        public let overview:String
        public let poster_path:URL
        public let vote_average:Float
        
        var domainMovie: DomainMovie {
            return DomainMovie(id: id, title: title, description: overview, poster: poster_path, rating: vote_average)
        }
    }
    
    static var OK_200: Int { return 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [DomainMovie] {
        guard response.statusCode == OK_200 else {
            throw RemoteMovieLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.results.map { $0.domainMovie }
    }
}
