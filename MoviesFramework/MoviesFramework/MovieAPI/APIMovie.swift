//
//  APIMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 02/01/2023.
//

import Foundation

internal struct APIMovie: Decodable {
    public let id:Int
    public let title:String
    public let overview:String
    public let poster_path:URL?
    public let vote_average:Float
}
