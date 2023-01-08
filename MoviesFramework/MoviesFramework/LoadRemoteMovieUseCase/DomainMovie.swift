//
//  DomainMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public struct DomainMovie: Hashable {
    public let id:Int
    public let title:String
    public let description:String
    public let poster:URL
    public let rating:Float
    public var isFavourite:Bool
    
    public init(id: Int, title: String, description: String, poster: URL, rating: Float, isFavourite:Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.poster = poster
        self.rating = rating
        self.isFavourite = isFavourite
    }
}
