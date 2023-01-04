//
//  MovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public struct StoreMovieDTO: Equatable {
    public let id:Int
    public let title:String
    public let description:String
    public let poster:URL
    public let rating:Float
    
    public init(id: Int, title: String, description: String, poster: URL, rating: Float) {
        self.id = id
        self.title = title
        self.description = description
        self.poster = poster
        self.rating = rating
    }
}


public protocol MovieStore {
    typealias insertionCompletion = (Error?) -> Void
    typealias retrivalCompletion = (Error?) -> Void
    
    func insert(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion)
    func retrieve(completion:@escaping retrivalCompletion)
}
