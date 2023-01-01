//
//  MovieItemsMapper.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

final class MovieItemsMapper {
    private struct Root: Decodable {
        let results: [APIMovie]
        var domainMovies: [DomainMovie] {
            results.map {$0.domainMovie}
        }
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
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteMovieLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteMovieLoader.Error.invalidData)
        }
        return .success(root.domainMovies)
    }
}
