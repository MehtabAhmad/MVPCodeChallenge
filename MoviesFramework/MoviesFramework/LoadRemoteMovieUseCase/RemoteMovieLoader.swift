//
//  RemoteMovieLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public typealias Url = () -> URL

final public class RemoteMovieLoader: LoadMovieUseCase {
    private let client:HTTPClient
    private let url:Url
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadMovieResult
    
    public init(client:HTTPClient, url: @escaping Url) {
        self.client = client
        self.url = url
    }
    
    public func load(completion:@escaping (Result) -> Void) {
        client.get(from: url()) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteMovieLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let apiMovies = try MovieItemsMapper.map(data, from: response)
            return .success(apiMovies.toDomainMovies())
        }
        catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == APIMovie {
    func toDomainMovies() -> [DomainMovie] {
        return map { DomainMovie(id: $0.id, title: $0.title, description: $0.overview, poster: URL(string: "https://image.tmdb.org/t/p/w400/\($0.poster_path.absoluteString)")!, rating: $0.vote_average)}
    }
}
