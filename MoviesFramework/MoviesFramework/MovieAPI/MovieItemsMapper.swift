//
//  MovieItemsMapper.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

internal struct APIMovie: Decodable {
    public let id:Int
    public let title:String
    public let overview:String
    public let poster_path:URL
    public let vote_average:Float
}

final class MovieItemsMapper {
    private struct Root: Decodable {
        let results: [APIMovie]
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [APIMovie] {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteMovieLoader.Error.invalidData
        }
        return root.results
    }
}
